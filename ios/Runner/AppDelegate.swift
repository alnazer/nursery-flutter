import AVFoundation
import Flutter
import UIKit
import LocalAuthentication
import Security

/// الجسر بين Flutter والكود الأصلي على iOS: معلومات الجهاز، وKeychain، وSecure Enclave.
/// بلا أي مكتبة خارجية.
@main
@objc class AppDelegate: FlutterAppDelegate {

  private static let channelName = "nursery/native"
  private static let keyTag = "com.nursery.biometric.key".data(using: .utf8)!
  private static let keychainService = "com.nursery.secure"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: AppDelegate.channelName,
                                         binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { [weak self] call, result in
        self?.handle(call: call, result: result)
      }
    }
    GeneratedPluginRegistrant.register(with: self)

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - القناة

  private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "deviceInfo":
      result(deviceInfo())
    case "openUrl":
      result(openUrl(args["url"] as? String))
    case "scanCode":
      startScan(result: result)
    case "secureRead":
      result(keychainRead(key: args["key"] as? String ?? ""))
    case "secureWrite":
      keychainWrite(key: args["key"] as? String ?? "", value: args["value"] as? String)
      result(nil)
    case "secureDelete":
      keychainWrite(key: args["key"] as? String ?? "", value: nil)
      result(nil)
    case "biometricStatus":
      result(biometricStatus())
    case "biometricHasKey":
      result(hasBiometricKey())
    case "biometricCreateKey":
      createBiometricKey(result: result)
    case "biometricDeleteKey":
      deleteBiometricKey()
      result(nil)
    case "biometricSign":
      sign(message: args["message"] as? String ?? "",
           reason: (args["subtitle"] as? String) ?? (args["title"] as? String) ?? "",
           cancel: args["cancel"] as? String,
           result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// يفتح شاشة مسح الرمز ويعيد نصه (أو nil عند الإلغاء).
  private func startScan(result: @escaping FlutterResult) {
    guard let root = window?.rootViewController else {
      result(nil)
      return
    }
    let scanner = NurseryScannerViewController()
    scanner.modalPresentationStyle = .fullScreen
    scanner.onResult = { value in
      root.dismiss(animated: true) { result(value) }
    }
    root.present(scanner, animated: true, completion: nil)
  }

  /// يفتح رابطاً في متصفح النظام (صفحة الدفع، الإيصال، المرفقات).
  private func openUrl(_ raw: String?) -> Bool {
    guard let raw = raw, let url = URL(string: raw), UIApplication.shared.canOpenURL(url) else {
      return false
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)

    return true
  }

  private func deviceInfo() -> [String: Any] {
    let info = Bundle.main.infoDictionary
    return [
      "platform": "ios",
      "deviceName": UIDevice.current.name,
      "osVersion": UIDevice.current.systemVersion,
      "appVersion": (info?["CFBundleShortVersionString"] as? String) ?? "",
      "appBuild": Int((info?["CFBundleVersion"] as? String) ?? "0") ?? 0,
    ]
  }

  // MARK: - التخزين الآمن (Keychain)

  private func keychainQuery(key: String) -> [String: Any] {
    return [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: AppDelegate.keychainService,
      kSecAttrAccount as String: key,
    ]
  }

  private func keychainRead(key: String) -> String? {
    var query = keychainQuery(key: key)
    query[kSecReturnData as String] = true
    query[kSecMatchLimit as String] = kSecMatchLimitOne
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
          let data = item as? Data else {
      return nil
    }

    return String(data: data, encoding: .utf8)
  }

  private func keychainWrite(key: String, value: String?) {
    let query = keychainQuery(key: key)
    SecItemDelete(query as CFDictionary)
    guard let value = value, let data = value.data(using: .utf8) else {
      return
    }
    var insert = query
    insert[kSecValueData as String] = data
    insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    SecItemAdd(insert as CFDictionary, nil)
  }

  // MARK: - البصمة

  private func biometricStatus() -> String {
    var error: NSError?
    let context = LAContext()
    if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
      return "available"
    }
    switch error?.code {
    case LAError.biometryNotEnrolled.rawValue:
      return "not_enrolled"
    case LAError.biometryNotAvailable.rawValue:
      return "no_hardware"
    default:
      return "unavailable"
    }
  }

  private func biometricKeyQuery() -> [String: Any] {
    return [
      kSecClass as String: kSecClassKey,
      kSecAttrApplicationTag as String: AppDelegate.keyTag,
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
    ]
  }

  private func hasBiometricKey() -> Bool {
    var query = biometricKeyQuery()
    query[kSecReturnRef as String] = true
    query[kSecUseAuthenticationUI as String] = kSecUseAuthenticationUISkip
    let status = SecItemCopyMatching(query as CFDictionary, nil)

    return status == errSecSuccess || status == errSecInteractionNotAllowed
  }

  private func deleteBiometricKey() {
    SecItemDelete(biometricKeyQuery() as CFDictionary)
  }

  private func createBiometricKey(result: @escaping FlutterResult) {
    deleteBiometricKey()
    var error: Unmanaged<CFError>?
    guard let access = SecAccessControlCreateWithFlags(
      nil,
      kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
      [.privateKeyUsage, .biometryCurrentSet],
      &error) else {
      result(FlutterError(code: "key_failed", message: "access control", details: nil))
      return
    }

    var attributes: [String: Any] = [
      kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
      kSecAttrKeySizeInBits as String: 256,
      kSecPrivateKeyAttrs as String: [
        kSecAttrIsPermanent as String: true,
        kSecAttrApplicationTag as String: AppDelegate.keyTag,
        kSecAttrAccessControl as String: access,
      ],
    ]
    #if !targetEnvironment(simulator)
    attributes[kSecAttrTokenID as String] = kSecAttrTokenIDSecureEnclave
    #endif

    guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error),
          let publicKey = SecKeyCopyPublicKey(privateKey),
          let raw = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
      result(FlutterError(code: "key_failed", message: "create key", details: nil))
      return
    }

    result(subjectPublicKeyInfo(from: raw).base64EncodedString())
  }

  /// يلفّ نقطة X9.63 في SubjectPublicKeyInfo لمنحنى P-256 كما يتوقعها الخادم.
  private func subjectPublicKeyInfo(from raw: Data) -> Data {
    let header: [UInt8] = [
      0x30, 0x59, 0x30, 0x13, 0x06, 0x07, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x02, 0x01,
      0x06, 0x08, 0x2a, 0x86, 0x48, 0xce, 0x3d, 0x03, 0x01, 0x07, 0x03, 0x42, 0x00,
    ]
    var data = Data(header)
    data.append(raw)

    return data
  }

  private func sign(message: String, reason: String, cancel: String?, result: @escaping FlutterResult) {
    let context = LAContext()
    context.localizedReason = reason
    if let cancel = cancel {
      context.localizedCancelTitle = cancel
    }
    var query = biometricKeyQuery()
    query[kSecReturnRef as String] = true
    query[kSecUseAuthenticationContext as String] = context

    DispatchQueue.global(qos: .userInitiated).async {
      var item: CFTypeRef?
      let status = SecItemCopyMatching(query as CFDictionary, &item)
      guard status == errSecSuccess, let key = item else {
        DispatchQueue.main.async {
          result(FlutterError(code: status == errSecItemNotFound ? "no_key" : "key_invalidated",
                              message: "key unavailable (\(status))", details: nil))
        }
        return
      }

      var error: Unmanaged<CFError>?
      let data = Data(message.utf8)
      let signature = SecKeyCreateSignature(key as! SecKey,
                                            .ecdsaSignatureMessageX962SHA256,
                                            data as CFData,
                                            &error) as Data?
      DispatchQueue.main.async {
        if let signature = signature {
          result(signature.base64EncodedString())
          return
        }
        var code = 0
        if let failure = error?.takeRetainedValue() {
          code = CFErrorGetCode(failure)
        }
        if code == LAError.userCancel.rawValue || code == Int(errSecUserCanceled) {
          result(FlutterError(code: "cancelled", message: "cancelled", details: nil))
        } else {
          result(FlutterError(code: "sign_failed", message: "signature failed (\(code))", details: nil))
        }
      }
    }
  }
}


/// شاشة مسح بسيطة على AVFoundation — بلا مكتبات خارجية.
final class NurseryScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

  var onResult: ((String?) -> Void)?

  private let session = AVCaptureSession()
  private var preview: AVCaptureVideoPreviewLayer?
  private var finished = false

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    guard let device = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: device),
          session.canAddInput(input) else {
      finish(nil)
      return
    }
    session.addInput(input)

    let output = AVCaptureMetadataOutput()
    guard session.canAddOutput(output) else {
      finish(nil)
      return
    }
    session.addOutput(output)
    output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
    output.metadataObjectTypes = [.qr, .code128, .code39, .ean13]

    let layer = AVCaptureVideoPreviewLayer(session: session)
    layer.videoGravity = .resizeAspectFill
    layer.frame = view.bounds
    view.layer.addSublayer(layer)
    preview = layer

    let close = UIButton(type: .system)
    close.setTitle("✕", for: .normal)
    close.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    close.tintColor = .white
    close.translatesAutoresizingMaskIntoConstraints = false
    close.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    view.addSubview(close)
    NSLayoutConstraint.activate([
      close.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
      close.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
      close.widthAnchor.constraint(equalToConstant: 44),
      close.heightAnchor.constraint(equalToConstant: 44),
    ])

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.session.startRunning()
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    preview?.frame = view.bounds
  }

  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {
    guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          let value = object.stringValue else {
      return
    }
    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    finish(value)
  }

  @objc private func cancelTapped() {
    finish(nil)
  }

  private func finish(_ value: String?) {
    if finished {
      return
    }
    finished = true
    if session.isRunning {
      session.stopRunning()
    }
    onResult?(value)
  }
}

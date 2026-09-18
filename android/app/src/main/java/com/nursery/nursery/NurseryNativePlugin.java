package com.nursery.nursery;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.net.Uri;
import android.os.Build;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;

import com.google.mlkit.vision.barcode.common.Barcode;
import com.google.mlkit.vision.codescanner.GmsBarcodeScanner;
import com.google.mlkit.vision.codescanner.GmsBarcodeScannerOptions;
import com.google.mlkit.vision.codescanner.GmsBarcodeScanning;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * الجسر بين Flutter والكود الأصلي: معلومات الجهاز، والتخزين الآمن، والبصمة.
 * بلا أي مكتبة خارجية — Android Keystore وBiometricPrompt من النظام.
 */
public class NurseryNativePlugin implements MethodChannel.MethodCallHandler {

    public static final String CHANNEL = "nursery/native";

    private final Activity activity;
    private final SecureStore store;
    private final BiometricAuth biometric;

    private NurseryNativePlugin(Activity activity) {
        this.activity = activity;
        this.store = new SecureStore(activity);
        this.biometric = new BiometricAuth(activity);
    }

    static void register(FlutterEngine engine, Activity activity) {
        MethodChannel channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), CHANNEL);
        channel.setMethodCallHandler(new NurseryNativePlugin(activity));
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        try {
            switch (call.method) {
                case "deviceInfo":
                    result.success(deviceInfo());
                    return;
                case "scanCode":
                    scanCode(result);
                    return;
                case "openUrl":
                    result.success(openUrl(call.<String>argument("url")));
                    return;
                case "secureRead":
                    result.success(store.read(call.<String>argument("key")));
                    return;
                case "secureWrite":
                    store.write(call.<String>argument("key"), call.<String>argument("value"));
                    result.success(null);
                    return;
                case "secureDelete":
                    store.delete(call.<String>argument("key"));
                    result.success(null);
                    return;
                case "biometricStatus":
                    result.success(biometric.status());
                    return;
                case "biometricHasKey":
                    result.success(biometric.hasKey());
                    return;
                case "biometricCreateKey":
                    result.success(biometric.createKey());
                    return;
                case "biometricDeleteKey":
                    biometric.deleteKey();
                    result.success(null);
                    return;
                case "biometricSign":
                    biometric.sign(
                            call.<String>argument("message"),
                            call.<String>argument("title"),
                            call.<String>argument("subtitle"),
                            call.<String>argument("cancel"),
                            result);
                    return;
                default:
                    result.notImplemented();
            }
        } catch (Exception e) {
            result.error("native_error", e.getMessage(), null);
        }
    }

    /** يفتح شاشة المسح من خدمات Google ويعيد نص الرمز (أو null عند الإلغاء). */
    private void scanCode(final MethodChannel.Result result) {
        GmsBarcodeScannerOptions options = new GmsBarcodeScannerOptions.Builder()
                .setBarcodeFormats(Barcode.FORMAT_QR_CODE, Barcode.FORMAT_CODE_128, Barcode.FORMAT_CODE_39)
                .enableAutoZoom()
                .build();
        GmsBarcodeScanner scanner = GmsBarcodeScanning.getClient(activity, options);
        scanner.startScan()
               .addOnSuccessListener(new com.google.android.gms.tasks.OnSuccessListener<Barcode>() {
                   @Override
                   public void onSuccess(Barcode barcode) {
                       result.success(barcode == null ? null : barcode.getRawValue());
                   }
               })
               .addOnCanceledListener(new com.google.android.gms.tasks.OnCanceledListener() {
                   @Override
                   public void onCanceled() {
                       result.success(null);
                   }
               })
               .addOnFailureListener(new com.google.android.gms.tasks.OnFailureListener() {
                   @Override
                   public void onFailure(Exception error) {
                       result.error("scan_failed", error.getMessage(), null);
                   }
               });
    }

    /** يفتح رابطاً في المتصفح (صفحة الدفع، الإيصال، المرفقات). */
    private boolean openUrl(String url) {
        if (url == null || url.isEmpty()) {
            return false;
        }
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            activity.startActivity(intent);

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private Map<String, Object> deviceInfo() {
        Map<String, Object> info = new HashMap<>();
        info.put("platform", "android");
        info.put("deviceName", (Build.MANUFACTURER + " " + Build.MODEL).trim());
        info.put("osVersion", Build.VERSION.RELEASE);
        String version = "";
        int build = 0;
        try {
            PackageInfo pkg = activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0);
            version = pkg.versionName == null ? "" : pkg.versionName;
            build = (int) pkg.getLongVersionCode();
        } catch (Exception ignored) {
        }
        info.put("appVersion", version);
        info.put("appBuild", build);
        return info;
    }
}

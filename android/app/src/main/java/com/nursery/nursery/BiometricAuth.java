package com.nursery.nursery;

import android.app.Activity;
import android.content.Context;
import android.hardware.biometrics.BiometricManager;
import android.hardware.biometrics.BiometricPrompt;
import android.os.Build;
import android.os.CancellationSignal;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyPermanentlyInvalidatedException;
import android.security.keystore.KeyProperties;
import android.util.Base64;

import java.nio.charset.Charset;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.ECGenParameterSpec;

import io.flutter.plugin.common.MethodChannel;

/**
 * مفتاح EC P-256 داخل Android Keystore لا يُستخدم إلا بعد بصمة صحيحة.
 * الخادم يحفظ المفتاح العام فقط، والبصمة نفسها لا تغادر الجهاز.
 */
class BiometricAuth {

    private static final String ALIAS = "nursery_bio_v1";

    /** زر الإلغاء في شاشة النظام — ثابته غير معلن في BiometricPrompt العام */
    private static final int ERROR_NEGATIVE_BUTTON = 13;
    private static final Charset UTF8 = Charset.forName("UTF-8");

    private final Activity activity;

    BiometricAuth(Activity activity) {
        this.activity = activity;
    }

    @SuppressWarnings("deprecation")
    String status() {
        BiometricManager manager = (BiometricManager) activity.getSystemService(Context.BIOMETRIC_SERVICE);
        if (manager == null) {
            return "unavailable";
        }
        int code = manager.canAuthenticate();
        switch (code) {
            case BiometricManager.BIOMETRIC_SUCCESS:
                return "available";
            case BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED:
                return "not_enrolled";
            case BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE:
                return "no_hardware";
            default:
                return "unavailable";
        }
    }

    boolean hasKey() throws Exception {
        return keyStore().containsAlias(ALIAS);
    }

    void deleteKey() throws Exception {
        KeyStore keyStore = keyStore();
        if (keyStore.containsAlias(ALIAS)) {
            keyStore.deleteEntry(ALIAS);
        }
    }

    /** ينشئ زوج مفاتيح جديداً ويعيد المفتاح العام (SubjectPublicKeyInfo) بصيغة base64. */
    String createKey() throws Exception {
        deleteKey();
        KeyPairGenerator generator = KeyPairGenerator.getInstance(KeyProperties.KEY_ALGORITHM_EC, "AndroidKeyStore");
        KeyGenParameterSpec.Builder builder = new KeyGenParameterSpec.Builder(ALIAS, KeyProperties.PURPOSE_SIGN)
                .setAlgorithmParameterSpec(new ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(true)
                .setInvalidatedByBiometricEnrollment(true);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG);
        }
        generator.initialize(builder.build());
        KeyPair pair = generator.generateKeyPair();

        return Base64.encodeToString(pair.getPublic().getEncoded(), Base64.NO_WRAP);
    }

    /** يعرض شاشة البصمة ثم يوقّع النص بـ SHA256withECDSA (التوقيع DER). */
    void sign(final String message, String title, String subtitle, String cancel, final MethodChannel.Result result) {
        final Signature signature;
        try {
            PrivateKey key = (PrivateKey) keyStore().getKey(ALIAS, null);
            if (key == null) {
                result.error("no_key", "biometric key missing", null);
                return;
            }
            signature = Signature.getInstance("SHA256withECDSA");
            signature.initSign(key);
        } catch (KeyPermanentlyInvalidatedException e) {
            result.error("key_invalidated", e.getMessage(), null);
            return;
        } catch (Exception e) {
            result.error("sign_failed", e.getMessage(), null);
            return;
        }

        BiometricPrompt prompt = new BiometricPrompt.Builder(activity)
                .setTitle(title == null ? "" : title)
                .setSubtitle(subtitle == null ? "" : subtitle)
                .setNegativeButton(cancel == null ? "Cancel" : cancel, activity.getMainExecutor(),
                        new android.content.DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(android.content.DialogInterface dialog, int which) {
                                // النتيجة تصل من onAuthenticationError
                            }
                        })
                .build();

        prompt.authenticate(new BiometricPrompt.CryptoObject(signature), new CancellationSignal(),
                activity.getMainExecutor(), new BiometricPrompt.AuthenticationCallback() {
                    private boolean done = false;

                    @Override
                    public void onAuthenticationSucceeded(BiometricPrompt.AuthenticationResult authResult) {
                        if (done) {
                            return;
                        }
                        done = true;
                        try {
                            Signature signed = authResult.getCryptoObject().getSignature();
                            signed.update(message.getBytes(UTF8));
                            result.success(Base64.encodeToString(signed.sign(), Base64.NO_WRAP));
                        } catch (Exception e) {
                            result.error("sign_failed", e.getMessage(), null);
                        }
                    }

                    @Override
                    public void onAuthenticationError(int errorCode, CharSequence errString) {
                        if (done) {
                            return;
                        }
                        done = true;
                        result.error(mapError(errorCode), errString == null ? null : errString.toString(), null);
                    }
                });
    }

    private String mapError(int code) {
        switch (code) {
            case BiometricPrompt.BIOMETRIC_ERROR_USER_CANCELED:
            case ERROR_NEGATIVE_BUTTON:
            case BiometricPrompt.BIOMETRIC_ERROR_CANCELED:
                return "cancelled";
            case BiometricPrompt.BIOMETRIC_ERROR_LOCKOUT:
            case BiometricPrompt.BIOMETRIC_ERROR_LOCKOUT_PERMANENT:
                return "locked";
            case BiometricPrompt.BIOMETRIC_ERROR_NO_BIOMETRICS:
                return "not_enrolled";
            default:
                return "unavailable";
        }
    }

    private KeyStore keyStore() throws Exception {
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);

        return keyStore;
    }
}

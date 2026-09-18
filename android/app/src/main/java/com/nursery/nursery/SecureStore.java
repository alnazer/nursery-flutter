package com.nursery.nursery;

import android.content.Context;
import android.content.SharedPreferences;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.util.Base64;

import java.nio.charset.Charset;
import java.security.KeyStore;
import java.security.SecureRandom;
import java.util.Arrays;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;

/**
 * تخزين مشفّر: المفتاح داخل Android Keystore ولا يخرج منه، والنص المشفّر في SharedPreferences.
 */
class SecureStore {

    private static final String PREFS = "nursery_secure";
    private static final String ALIAS = "nursery_secure_v1";
    private static final Charset UTF8 = Charset.forName("UTF-8");
    private static final int IV_LENGTH = 12;
    private static final int TAG_BITS = 128;

    private final SharedPreferences prefs;

    SecureStore(Context context) {
        this.prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    String read(String key) {
        String raw = prefs.getString(key, null);
        if (raw == null) {
            return null;
        }
        try {
            byte[] blob = Base64.decode(raw, Base64.NO_WRAP);
            byte[] iv = Arrays.copyOfRange(blob, 0, IV_LENGTH);
            byte[] cipherText = Arrays.copyOfRange(blob, IV_LENGTH, blob.length);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, secretKey(), new GCMParameterSpec(TAG_BITS, iv));
            return new String(cipher.doFinal(cipherText), UTF8);
        } catch (Exception e) {
            // مفتاح التشفير تغيّر أو البيانات تالفة: نتعامل معها كأنها غير موجودة
            delete(key);
            return null;
        }
    }

    void write(String key, String value) throws Exception {
        if (value == null) {
            delete(key);
            return;
        }
        byte[] iv = new byte[IV_LENGTH];
        new SecureRandom().nextBytes(iv);
        Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey(), new GCMParameterSpec(TAG_BITS, iv));
        byte[] cipherText = cipher.doFinal(value.getBytes(UTF8));
        byte[] blob = new byte[iv.length + cipherText.length];
        System.arraycopy(iv, 0, blob, 0, iv.length);
        System.arraycopy(cipherText, 0, blob, iv.length, cipherText.length);
        prefs.edit().putString(key, Base64.encodeToString(blob, Base64.NO_WRAP)).apply();
    }

    void delete(String key) {
        prefs.edit().remove(key).apply();
    }

    private SecretKey secretKey() throws Exception {
        KeyStore keyStore = KeyStore.getInstance("AndroidKeyStore");
        keyStore.load(null);
        KeyStore.Entry entry = keyStore.getEntry(ALIAS, null);
        if (entry instanceof KeyStore.SecretKeyEntry) {
            return ((KeyStore.SecretKeyEntry) entry).getSecretKey();
        }
        KeyGenerator generator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore");
        generator.init(new KeyGenParameterSpec.Builder(ALIAS,
                KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
                .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
                .build());
        return generator.generateKey();
    }
}

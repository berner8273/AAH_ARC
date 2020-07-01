package com.aptitudesoftware.util;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;

import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import javax.crypto.spec.PBEParameterSpec;

import org.apache.commons.codec.binary.Base64;

public class TwoWayEncryptionUtil {

    private static final String PWDSTRING = "enfldsgbnlsngdlksdsgm";
    private static final char[] PASSWORD  = PWDSTRING.toCharArray();
    private static final byte[] SALT      = [
                                                (byte) 0xde, (byte) 0x33, (byte) 0x10, (byte) 0x12,
                                                (byte) 0xde, (byte) 0x33, (byte) 0x10, (byte) 0x12,
                                            ];

    private static String encodeBase64 ( byte [] bytes ) {
        return new Base64().encodeBase64String ( bytes );
    }

    private static byte[] base64Decode ( String property ) throws IOException {
        return new Base64().decodeBase64 ( property );
    }

    public static String decryptString ( String property ) throws GeneralSecurityException , IOException {
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance ( "PBEWithMD5AndDES" );
        SecretKey        key        = keyFactory.generateSecret ( new PBEKeySpec ( PASSWORD ) );
        Cipher pbeCipher = Cipher.getInstance ( "PBEWithMD5AndDES" );
        pbeCipher.init(Cipher.DECRYPT_MODE, key, new PBEParameterSpec ( SALT , 20 ) );
        return new String ( pbeCipher.doFinal ( base64Decode ( property ) ) , "UTF-8" );
    }

    public static String encryptString ( String property ) throws GeneralSecurityException , UnsupportedEncodingException {
        SecretKeyFactory keyFactory = SecretKeyFactory.getInstance ( "PBEWithMD5AndDES" );
        SecretKey        key        = keyFactory.generateSecret ( new PBEKeySpec ( PASSWORD ) );
        Cipher           pbeCipher  = Cipher.getInstance ( "PBEWithMD5AndDES" );
        pbeCipher.init ( Cipher.ENCRYPT_MODE , key , new PBEParameterSpec ( SALT , 20 ) );
        encodeBase64 ( pbeCipher.doFinal ( property.getBytes ( "UTF-8" ) ) );
    }
}
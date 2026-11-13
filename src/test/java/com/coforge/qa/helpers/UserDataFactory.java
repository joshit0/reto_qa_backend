package com.coforge.qa.helpers;

import java.security.SecureRandom;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.atomic.AtomicLong;


public final class UserDataFactory {

    private static final String ALPHANUMERIC =
            "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();
    private static final AtomicLong SEQUENCE = new AtomicLong(System.currentTimeMillis());

    private UserDataFactory() {
    }

    public static Map<String, Object> generarDataUsuario() {
        String suffix = SEQUENCE.incrementAndGet() + randomAlphanumeric(6);
        Map<String, Object> usuario = new LinkedHashMap<>();
        usuario.put("nome", "Usuario QA " + suffix);
        usuario.put("email", "qa." + suffix + "@serverest.dev");
        usuario.put("password", randomAlphanumeric(15));
        usuario.put("administrador", "true");
        return usuario;
    }

    public static Map<String, Object> generarDataUsuarioSinCampo(String campo) {
        Map<String, Object> usuario = generarDataUsuario();
        usuario.remove(campo);
        return usuario;
    }

    public static String randomAlphanumeric(int length) {
        StringBuilder value = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            value.append(ALPHANUMERIC.charAt(RANDOM.nextInt(ALPHANUMERIC.length())));
        }
        return value.toString();
    }
}

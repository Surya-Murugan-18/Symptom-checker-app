package com.sevai.sevaibackend.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

@Component
public class JwtAuthFilter extends OncePerRequestFilter {

    private final JwtService jwtService;

    public JwtAuthFilter(JwtService jwtService) {
        this.jwtService = jwtService;
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            System.out.println("❌ Auth Filter: Missing or invalid Authorization header");
            filterChain.doFilter(request, response);
            return;
        }

        try {
            String token = authHeader.substring(7).trim();
            if (token.isEmpty() || token.equalsIgnoreCase("null")) {
                System.out.println("⚠️ Auth Filter: Token is empty or 'null'. Skipping authentication.");
                filterChain.doFilter(request, response);
                return;
            }

            String email = jwtService.extractUsername(token);
            System.out.println("🔍 Auth Filter: Checking token for email: " + email);

            if (email != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                if (jwtService.isTokenValid(token)) {
                    System.out.println("✅ Auth Filter: Token is VALID. Setting SecurityContext.");
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            email,
                            null,
                            Collections.emptyList());

                    authToken.setDetails(
                            new WebAuthenticationDetailsSource().buildDetails(request));

                    SecurityContextHolder.getContext().setAuthentication(authToken);
                } else {
                    System.out.println("❌ Auth Filter: Token is INVALID.");
                }
            } else {
                System.out.println("⚠️ Auth Filter: Email null or Context already set.");
            }
        } catch (Exception e) {
            System.out.println("❌ Auth Filter: Error processing JWT token: " + e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}

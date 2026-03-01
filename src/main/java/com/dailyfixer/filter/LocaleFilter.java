package com.dailyfixer.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Locale;

@WebFilter("/*")
public class LocaleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(true);

        String lang = httpRequest.getParameter("lang");

        if (lang != null) {
            Locale locale;
            if ("si".equals(lang)) {
                locale = new Locale("si");
            } else {
                locale = Locale.ENGLISH;
            }
            session.setAttribute("sessionLocale", locale);

            // Redirect back to the same URL without the lang parameter
            String queryString = httpRequest.getQueryString();
            String requestURI = httpRequest.getRequestURI();

            // Remove lang parameter from query string
            if (queryString != null) {
                queryString = queryString.replaceAll("(&?lang=[^&]*)", "").replaceAll("^&", "");
            }

            String redirectURL = requestURI + (queryString != null && !queryString.isEmpty() ? "?" + queryString : "");
            httpResponse.sendRedirect(redirectURL);
            return;
        }

        if (session.getAttribute("sessionLocale") == null) {
            session.setAttribute("sessionLocale", Locale.ENGLISH);
        }

        chain.doFilter(request, response);
    }
}

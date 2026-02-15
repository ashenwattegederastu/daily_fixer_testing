package com.dailyfixer.servlet;

import com.dailyfixer.dao.VolunteerDAO;
import com.dailyfixer.model.Volunteer;
import com.dailyfixer.util.HashUtil;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;

@WebServlet(name = "RegisterVolunteerServlet", urlPatterns = {"/registerVolunteer"})
public class RegisterVolunteerServlet extends HttpServlet {

    private VolunteerDAO volunteerDAO = new VolunteerDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String firstName = req.getParameter("firstName");
        String lastName = req.getParameter("lastName");
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String phone = req.getParameter("phone");
        String city = req.getParameter("city");
        String expertise = req.getParameter("expertise");
        boolean agreement = req.getParameter("agreement") != null;

//        if (volunteerDAO.usernameExists(username)) {
//            req.setAttribute("error", "Username already exists!");
//            req.getRequestDispatcher("registerVolunteer.jsp").forward(req, resp);
//            return;
//        }

//        if (volunteerDAO.emailExists(email)) {
//            req.setAttribute("error", "Email already exists!");
//            req.getRequestDispatcher("registerVolunteer.jsp").forward(req, resp);
//            return;
//        }

        Volunteer volunteer = new Volunteer();
        volunteer.setFirstName(firstName);
        volunteer.setLastName(lastName);
        volunteer.setUsername(username);
        volunteer.setEmail(email);
        volunteer.setPassword(HashUtil.sha256(password));
        volunteer.setPhoneNumber(phone);
        volunteer.setCity(city);
        volunteer.setExpertise(expertise);
        volunteer.setAgreement(agreement);

        boolean success = volunteerDAO.registerVolunteer(volunteer);

        if (success) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp?success=volunteerRegistered");
        } else {
            req.setAttribute("error", "Registration failed. Please try again.");
            req.getRequestDispatcher("registerVolunteer.jsp").forward(req, resp);
        }
    }
}

package com.dailyfixer.job;

import com.dailyfixer.dao.DeliveryAssignmentDAO;
import com.dailyfixer.dao.DeliveryAssignmentDAO.StaleAssignment;
import com.dailyfixer.dao.OrderDAO;
import com.dailyfixer.util.EmailUtil;

import java.math.BigDecimal;
import java.util.List;

/**
 * Background job that detects delivery assignments stuck in PENDING status
 * for longer than TIMEOUT_HOURS hours, then:
 *  1. Cancels the delivery_assignment (status → CANCELLED)
 *  2. Marks the order as REFUND_PENDING with a reason
 *  3. Emails the store owner to notify them
 *  4. Emails the buyer to confirm a refund is being processed
 * Scheduled by AppStartupListener every 15 minutes.
 */
public class DeliveryTimeoutJob implements Runnable {

    /** Assignments idle longer than this will be cancelled and refunded. */
    private static final int TIMEOUT_HOURS = 48;

    private final DeliveryAssignmentDAO assignmentDAO = new DeliveryAssignmentDAO();
    private final OrderDAO orderDAO = new OrderDAO();

    @Override
    public void run() {
        System.out.println("[DeliveryTimeoutJob] Running check for stale assignments (>" + TIMEOUT_HOURS + "h)...");
        try {
            List<StaleAssignment> staleList = assignmentDAO.getStaleAssignments(TIMEOUT_HOURS);
            System.out.println("[DeliveryTimeoutJob] Found " + staleList.size() + " stale assignment(s).");

            for (StaleAssignment s : staleList) {
                processStaleAssignment(s);
            }
        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Unexpected error during run: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void processStaleAssignment(StaleAssignment s) {
        System.out.println("[DeliveryTimeoutJob] Processing stale assignment #" + s.assignmentId
                + " (order " + s.orderId + ")");
        try {
            // 1. Cancel the delivery assignment
            boolean cancelled = assignmentDAO.cancelAssignment(s.assignmentId);
            if (!cancelled) {
                System.err.println("[DeliveryTimeoutJob] Could not cancel assignment #" + s.assignmentId
                        + " — may have already been handled.");
                return;
            }

            // 2. Mark order as REFUND_PENDING
            orderDAO.markRefundPending(s.orderId,
                    "No driver was assigned within " + TIMEOUT_HOURS + " hours of dispatch.");

            // 3. Notify store owner
            if (s.storeOwnerEmail != null && !s.storeOwnerEmail.isBlank()) {
                try {
                    EmailUtil.sendEmail(
                            s.storeOwnerEmail,
                            "Delivery Cancelled – Order " + s.orderId,
                            buildStoreEmail(s)
                    );
                } catch (Exception e) {
                    System.err.println("[DeliveryTimeoutJob] Failed to email store owner ("
                            + s.storeOwnerEmail + "): " + e.getMessage());
                }
            }

            // 4. Notify buyer
            if (s.buyerEmail != null && !s.buyerEmail.isBlank()) {
                try {
                    EmailUtil.sendEmail(
                            s.buyerEmail,
                            "Your Order " + s.orderId + " – Refund Initiated",
                            buildBuyerEmail(s)
                    );
                } catch (Exception e) {
                    System.err.println("[DeliveryTimeoutJob] Failed to email buyer ("
                            + s.buyerEmail + "): " + e.getMessage());
                }
            }

            System.out.println("[DeliveryTimeoutJob] Completed processing for assignment #" + s.assignmentId);

        } catch (Exception e) {
            System.err.println("[DeliveryTimeoutJob] Error processing assignment #"
                    + s.assignmentId + ": " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ── Email templates ───────────────────────────────────────────────────────

    private String buildStoreEmail(StaleAssignment s) {
        String amount = formatAmount(s.totalAmount, s.currency);
        return "<div style='font-family:Inter,sans-serif;max-width:600px;margin:0 auto;padding:24px;'>"
             + "<h2 style='color:#dc3545;'>Delivery Assignment Cancelled</h2>"
             + "<p>Hi <strong>" + escHtml(s.storeName) + "</strong>,</p>"
             + "<p>Unfortunately, no driver was assigned to the following order within <strong>"
             + TIMEOUT_HOURS + " hours</strong> of dispatch. The delivery assignment has been automatically cancelled.</p>"
             + "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;width:40%;'>Order ID</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + escHtml(s.orderId) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Customer</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + escHtml(s.buyerName) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Order Amount</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + amount + "</td></tr>"
             + "</table>"
             + "<p>The customer will be refunded in full. If you believe this was an error, "
             + "please contact support.</p>"
             + "<p style='color:#6c757d;font-size:0.9em;margin-top:30px;'>– The Daily Fixer Team</p>"
             + "</div>";
    }

    private String buildBuyerEmail(StaleAssignment s) {
        String amount = formatAmount(s.totalAmount, s.currency);
        return "<div style='font-family:Inter,sans-serif;max-width:600px;margin:0 auto;padding:24px;'>"
             + "<h2 style='color:#0d6efd;'>Refund Initiated for Order " + escHtml(s.orderId) + "</h2>"
             + "<p>Hi <strong>" + escHtml(s.buyerName) + "</strong>,</p>"
             + "<p>We're sorry — we were unable to find a driver for your order from "
             + "<strong>" + escHtml(s.storeName) + "</strong> within " + TIMEOUT_HOURS + " hours.</p>"
             + "<p>Your order has been cancelled and a full refund of <strong>" + amount + "</strong> "
             + "has been initiated. Refunds typically appear within 5–7 business days depending on your bank.</p>"
             + "<table style='width:100%;border-collapse:collapse;margin:20px 0;'>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;width:40%;'>Order ID</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + escHtml(s.orderId) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Store</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + escHtml(s.storeName) + "</td></tr>"
             + "<tr><td style='padding:10px;background:#f8f9fa;font-weight:600;'>Refund Amount</td>"
             + "    <td style='padding:10px;border-bottom:1px solid #dee2e6;'>" + amount + "</td></tr>"
             + "</table>"
             + "<p>We apologise for the inconvenience. If you have questions, please contact our support team.</p>"
             + "<p style='color:#6c757d;font-size:0.9em;margin-top:30px;'>– The Daily Fixer Team</p>"
             + "</div>";
    }

    private String formatAmount(BigDecimal amount, String currency) {
        if (amount == null) return "—";
        String cur = (currency != null ? currency : "LKR");
        return cur + " " + String.format("%,.2f", amount);
    }

    /** Minimal HTML escaping to prevent XSS in email bodies. */
    private String escHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;");
    }
}

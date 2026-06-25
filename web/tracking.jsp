<%@ page import="java.sql.*" %>
<%@ page import="com.connection.DBConnection" %>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="style.css">

<%
if(session.getAttribute("user") == null){
    response.sendRedirect("login.jsp?msg=loginRequired");
    return;
}

String orderId = request.getParameter("orderId");
if(orderId == null || orderId.trim().equals("")){
    orderId = (String) session.getAttribute("lastOrderId");
}
if(orderId == null || orderId.trim().equals("")){
    orderId = (String) session.getAttribute("orderId");
}

String status = "Pending";
double total = 0.0;
String createdAt = "";
boolean foundOrder = false;
Connection conn = null;

if(orderId != null && !orderId.trim().equals("")){
    try {
        conn = DBConnection.getConnection();
        if(conn != null){
            PreparedStatement ps = conn.prepareStatement(
                "SELECT order_id, total, status, created_at FROM orders WHERE order_id = ?"
            );
            ps.setString(1, orderId);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                foundOrder = true;
                status = rs.getString("status");
                total = rs.getDouble("total");
                createdAt = String.valueOf(rs.getTimestamp("created_at"));
                session.setAttribute("lastOrderId", orderId);
            }
            rs.close();
            ps.close();
        }
    } catch(Exception e){
        out.println("<div class='error-message'>Tracking Error: " + e.getMessage() + "</div>");
    } finally {
        if(conn != null) {
            try { conn.close(); } catch(Exception e){}
        }
    }
}

boolean isCancelled = status != null && status.equalsIgnoreCase("Cancelled");
boolean isPending = status != null && status.equalsIgnoreCase("Pending");
boolean isPreparing = status != null && status.equalsIgnoreCase("Preparing");
boolean isReady = status != null && (status.equalsIgnoreCase("Ready to Pickup") || status.equalsIgnoreCase("Ready") || status.equalsIgnoreCase("Complete"));
%>

<div class="tracking-page-v2">
    <div class="tracking-card-v2">

        <% if(!foundOrder){ %>
            <div class="tracking-head-v2">
                <p class="eyebrow">Order Tracking</p>
                <h1>No Order Found</h1>
                <p>Your placed order will appear here after checkout and payment are completed.</p>
            </div>
            <div class="tracking-actions-v2">
                <button type="button" onclick="window.location.href='menu.jsp'">Back to Menu</button>
                <button type="button" onclick="window.location.href='orderHistory.jsp'">Order History</button>
            </div>
        <% } else { %>
            <div class="tracking-head-v2">
                <p class="eyebrow">Order Tracking</p>
                <h1>Track Order</h1>
                <p>Order ID: <b><%= orderId %></b></p>
                <p>Total: <b>RM <%= String.format("%.2f", total) %></b></p>
                <div class="status-pill-v2 <%= isCancelled ? "cancelled" : "" %>"><%= status %></div>
            </div>

            <div class="tracking-steps-v2">
                <div class="tracking-step-v2 <%= (!isCancelled && (isPending || isPreparing || isReady)) ? "active" : "" %>">
                    <div class="step-number">1</div>
                    <div>
                        <h3>Pending</h3>
                        <p>Your order has been received.</p>
                    </div>
                </div>

                <div class="tracking-step-v2 <%= (!isCancelled && (isPreparing || isReady)) ? "active" : "" %>">
                    <div class="step-number">2</div>
                    <div>
                        <h3>Preparing</h3>
                        <p>Kitchen is preparing your order.</p>
                    </div>
                </div>

                <div class="tracking-step-v2 <%= (!isCancelled && isReady) ? "active" : "" %>">
                    <div class="step-number">3</div>
                    <div>
                        <h3>Ready to Pickup</h3>
                        <p>Your order is ready at the counter.</p>
                    </div>
                </div>
            </div>

            <div class="tracking-actions-v2">
                <button type="button" onclick="window.location.href='orderHistory.jsp'">Order History</button>
                <button type="button" onclick="window.location.reload()">Refresh Status</button>
            </div>
        <% } %>

    </div>
</div>

<%@ include file="footer.jsp" %>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="com.connection.DBConnection"%>

<%@ include file="header.jsp" %>

<%
if(session.getAttribute("user") == null){
    response.sendRedirect("login.jsp?msg=loginRequired");
    return;
}

class OrderRow {
    String orderId;
    String items;
    String total;
    String status;
    String createdAt;
}

List<OrderRow> orders = new ArrayList<OrderRow>();

Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try{
    conn = DBConnection.getConnection();

    if(conn != null){

        String sql =
            "SELECT o.order_id, o.total, o.status, o.created_at, " +
            "COALESCE(GROUP_CONCAT(CONCAT(oi.item_name, ' x', oi.qty) SEPARATOR ', '), '') AS items " +
            "FROM orders o " +
            "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
            "GROUP BY o.order_id, o.total, o.status, o.created_at " +
            "ORDER BY o.created_at DESC";

        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();

        while(rs.next()){
            OrderRow row = new OrderRow();

            row.orderId = rs.getString("order_id");
            row.total = String.format("%.2f", rs.getDouble("total"));
            row.status = rs.getString("status");
            row.createdAt = String.valueOf(rs.getTimestamp("created_at"));
            row.items = rs.getString("items");

            orders.add(row);
        }
    }

}catch(Exception e){
    out.println("<div style='color:red; text-align:center; margin:30px;'>Order History Error: " + e.getMessage() + "</div>");
}finally{
    try{ if(rs != null) rs.close(); }catch(Exception e){}
    try{ if(ps != null) ps.close(); }catch(Exception e){}
    try{ if(conn != null) conn.close(); }catch(Exception e){}
}
%>

<style>
.order-history-page{
    width:90%;
    margin:40px auto;
}

.order-card{
    background:white;
    border:1px solid #e5e5e5;
    border-radius:20px;
    padding:30px;
    box-shadow:0 8px 25px rgba(0,0,0,.05);
}

.order-card h1{
    margin:0 0 10px;
    color:#111;
}

.order-subtitle{
    color:#666;
    margin-bottom:25px;
}

.order-table-wrap{
    overflow-x:auto;
}

.order-table{
    width:100%;
    border-collapse:collapse;
    min-width:850px;
}

.order-table th{
    background:#f2f2f2;
    padding:15px;
    text-align:left;
    font-size:13px;
    text-transform:uppercase;
    color:#111;
}

.order-table td{
    padding:18px 15px;
    border-bottom:1px solid #eee;
    vertical-align:middle;
}

.order-id{
    font-weight:800;
}

.status-badge{
    background:#111;
    color:white;
    padding:7px 13px;
    border-radius:999px;
    font-size:12px;
    font-weight:800;
    text-transform:uppercase;
}

.track-btn{
    display:inline-block;
    background:#111;
    color:white;
    padding:10px 15px;
    border-radius:10px;
    text-decoration:none;
    font-weight:800;
}

.track-btn:hover{
    opacity:.85;
}

.empty-order{
    background:#f7f7f7;
    border-radius:18px;
    padding:55px 20px;
    text-align:center;
}

.empty-order h2{
    margin-bottom:10px;
}

.empty-order a{
    display:inline-block;
    margin-top:15px;
    background:#111;
    color:white;
    padding:12px 20px;
    border-radius:10px;
    text-decoration:none;
    font-weight:800;
}
</style>

<div class="order-history-page">

    <div class="order-card">

        <p style="font-weight:800; letter-spacing:3px; color:#777; font-size:13px;">
            MY ORDERS
        </p>

        <h1>Order History</h1>

        <p class="order-subtitle">
            Orders shown here are loaded directly from the MySQL database.
        </p>

        <% if(orders.isEmpty()){ %>

            <div class="empty-order">
                <h2>No order yet</h2>
                <p>Your order will appear here after payment is completed.</p>
                <a href="menu.jsp">Order Now</a>
            </div>

        <% } else { %>

            <div class="order-table-wrap">

                <table class="order-table">

                    <tr>
                        <th>Order ID</th>
                        <th>Items</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th>Action</th>
                    </tr>

                    <%
                    for(OrderRow o : orders){
                    %>

                    <tr>
                        <td class="order-id"><%= o.orderId %></td>

                        <td>
                            <%= (o.items == null || o.items.trim().isEmpty()) ? "-" : o.items %>
                        </td>

                        <td>
                            RM <%= o.total %>
                        </td>

                        <td>
                            <span class="status-badge">
                                <%= o.status %>
                            </span>
                        </td>

                        <td>
                            <%= o.createdAt %>
                        </td>

                        <td>
                            <a class="track-btn" href="tracking.jsp?orderId=<%= o.orderId %>">
                                Track
                            </a>
                        </td>
                    </tr>

                    <% } %>

                </table>

            </div>

        <% } %>

    </div>

</div>

<%@ include file="footer.jsp" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.Map"%>
<%@page import="java.util.HashMap"%>
<%@page import="com.connection.DBConnection"%>

<%
/* =========================
   LOGIN CHECK
========================= */
if(!"admin".equals(session.getAttribute("role"))){
    response.sendRedirect(request.getContextPath() + "/login.jsp");
    return;
}

/* =========================
   LIST DATA
========================= */
List<Map<String, String>> dbOrders = new ArrayList<Map<String, String>>();

List<String> transactions = (List<String>) session.getAttribute("transactionList");
if(transactions == null){
    transactions = new ArrayList<String>();
}

List<String> promos = (List<String>) application.getAttribute("promoList");
if(promos == null){
    promos = new ArrayList<String>();
    application.setAttribute("promoList", promos);
}

/* =========================
   MENU DATABASE ACTION
========================= */
String menuAction = request.getParameter("menuAction");

if(menuAction != null){

    Connection menuConn = null;
    PreparedStatement menuPs = null;

    try{
        menuConn = DBConnection.getConnection();

        if(menuConn == null){
            out.println("<div style='color:red;'>Database connection failed.</div>");
            return;
        }

        if("add".equals(menuAction)){

            String itemName = request.getParameter("itemName");
            String priceStr = request.getParameter("price");
            String image = request.getParameter("image");
            String category = request.getParameter("category");
            String description = request.getParameter("description");

            if(image == null || image.trim().isEmpty()){
                image = "default.jpeg";
            }

            if(description == null){
                description = "";
            }

            double price = Double.parseDouble(priceStr);

            menuPs = menuConn.prepareStatement(
                "INSERT INTO menu(item_name, price, image, category, description, status) VALUES (?,?,?,?,?,?)"
            );

            menuPs.setString(1, itemName.trim());
            menuPs.setDouble(2, price);
            menuPs.setString(3, image.trim());
            menuPs.setString(4, category.trim());
            menuPs.setString(5, description.trim());
            menuPs.setString(6, "Available");

            menuPs.executeUpdate();

            response.sendRedirect("admin.jsp");
            return;
        }

        else if("toggle".equals(menuAction)){

            int id = Integer.parseInt(request.getParameter("menuId"));
            String currentStatus = request.getParameter("currentStatus");

            String updatedStatus = "Available".equalsIgnoreCase(currentStatus)
                    ? "Out of Stock"
                    : "Available";

            menuPs = menuConn.prepareStatement(
                "UPDATE menu SET status=? WHERE id=?"
            );

            menuPs.setString(1, updatedStatus);
            menuPs.setInt(2, id);

            menuPs.executeUpdate();

            response.sendRedirect("admin.jsp");
            return;
        }

        else if("delete".equals(menuAction)){

            int id = Integer.parseInt(request.getParameter("menuId"));

            menuPs = menuConn.prepareStatement(
                "DELETE FROM menu WHERE id=?"
            );

            menuPs.setInt(1, id);
            menuPs.executeUpdate();

            response.sendRedirect("admin.jsp");
            return;
        }

    }catch(Exception e){
        out.println("<div style='color:red;'>Menu Error: " + e.getMessage() + "</div>");
    }finally{
        try{ if(menuPs != null) menuPs.close(); }catch(Exception e){}
        try{ if(menuConn != null) menuConn.close(); }catch(Exception e){}
    }
}

/* =========================
   UPDATE ORDER STATUS
========================= */
String updateOrderId = request.getParameter("updateOrderId");
String newStatus = request.getParameter("newStatus");
String cancelOrderId = request.getParameter("cancelOrderId");

if(updateOrderId != null && newStatus != null){

    Connection orderConn = null;
    PreparedStatement ps = null;

    try{
        orderConn = DBConnection.getConnection();

        if(orderConn != null){

            ps = orderConn.prepareStatement(
                "UPDATE orders SET status=? WHERE order_id=?"
            );

            ps.setString(1, newStatus);
            ps.setString(2, updateOrderId);
            ps.executeUpdate();

            response.sendRedirect("admin.jsp");
            return;
        }

    }catch(Exception e){
        out.println("<div style='color:red;'>Update Order Error: " + e.getMessage() + "</div>");
    }finally{
        try{ if(ps != null) ps.close(); }catch(Exception e){}
        try{ if(orderConn != null) orderConn.close(); }catch(Exception e){}
    }
}

if(cancelOrderId != null){

    Connection orderConn = null;
    PreparedStatement ps = null;

    try{
        orderConn = DBConnection.getConnection();

        if(orderConn != null){

            ps = orderConn.prepareStatement(
                "UPDATE orders SET status='Cancelled' WHERE order_id=?"
            );

            ps.setString(1, cancelOrderId);
            ps.executeUpdate();

            response.sendRedirect("admin.jsp");
            return;
        }

    }catch(Exception e){
        out.println("<div style='color:red;'>Cancel Order Error: " + e.getMessage() + "</div>");
    }finally{
        try{ if(ps != null) ps.close(); }catch(Exception e){}
        try{ if(orderConn != null) orderConn.close(); }catch(Exception e){}
    }
}

/* =========================
   ADD CASH FLOW TRANSACTION
========================= */
String txType = request.getParameter("txType");
String txDesc = request.getParameter("txDesc");
String txAmount = request.getParameter("txAmount");

if(txType != null && txDesc != null && txAmount != null){

    try{
        double amt = Double.parseDouble(txAmount);
        String cleanDesc = txDesc.trim().replace(":", " - ");

        transactions.add(txType + ":" + cleanDesc + ":" + String.format("%.2f", amt));
        session.setAttribute("transactionList", transactions);

        response.sendRedirect("admin.jsp");
        return;

    }catch(Exception e){}
}

/* =========================
   DELETE CASH FLOW TRANSACTION
========================= */
String delTx = request.getParameter("delTx");

if(delTx != null){

    try{
        int i = Integer.parseInt(delTx);

        if(i >= 0 && i < transactions.size()){
            transactions.remove(i);
            session.setAttribute("transactionList", transactions);
        }

        response.sendRedirect("admin.jsp");
        return;

    }catch(Exception e){}
}

/* =========================
   ADD PROMO
========================= */
String promoCode = request.getParameter("promoCode");
String promoType = request.getParameter("promoType");
String promoValue = request.getParameter("promoValue");
String promoDesc = request.getParameter("promoDesc");

if(promoCode != null && promoType != null && promoValue != null && promoDesc != null){

    try{
        double value = Double.parseDouble(promoValue);

        String code = promoCode.trim().toUpperCase().replace(":", "");
        String type = promoType.trim().toUpperCase();
        String desc = promoDesc.trim().replace(":", " - ");

        if(code.length() > 0 && value > 0 && ("PERCENT".equals(type) || "FIXED".equals(type))){

            boolean exists = false;

            for(String p : promos){

                String[] pData = p.split(":", 4);

                if(pData.length > 0 && code.equalsIgnoreCase(pData[0])){
                    exists = true;
                    break;
                }
            }

            if(!exists){
                promos.add(code + ":" + type + ":" + String.format("%.2f", value) + ":" + desc);
                application.setAttribute("promoList", promos);
            }
        }

        response.sendRedirect("admin.jsp");
        return;

    }catch(Exception e){}
}

/* =========================
   DELETE PROMO
========================= */
String delPromo = request.getParameter("delPromo");

if(delPromo != null){

    try{
        int i = Integer.parseInt(delPromo);

        if(i >= 0 && i < promos.size()){
            promos.remove(i);
            application.setAttribute("promoList", promos);
        }

        response.sendRedirect("admin.jsp");
        return;

    }catch(Exception e){}
}

session.setAttribute("transactionList", transactions);
application.setAttribute("promoList", promos);

/* =========================
   LOAD REAL CUSTOMER ORDERS
========================= */
Connection loadOrderConn = null;
PreparedStatement orderPs = null;
ResultSet orderRs = null;

try{
    loadOrderConn = DBConnection.getConnection();

    if(loadOrderConn != null){

        String sql =
            "SELECT o.order_id, o.total, o.status, o.created_at, " +
            "COALESCE(GROUP_CONCAT(CONCAT(oi.item_name, ' x', oi.qty) SEPARATOR ', '), '') AS items " +
            "FROM orders o " +
            "LEFT JOIN order_items oi ON o.order_id = oi.order_id " +
            "GROUP BY o.order_id, o.total, o.status, o.created_at " +
            "ORDER BY o.created_at DESC";

        orderPs = loadOrderConn.prepareStatement(sql);
        orderRs = orderPs.executeQuery();

        while(orderRs.next()){

            Map<String, String> row = new HashMap<String, String>();

            row.put("order_id", orderRs.getString("order_id"));
            row.put("total", String.format("%.2f", orderRs.getDouble("total")));
            row.put("status", orderRs.getString("status"));
            row.put("created_at", String.valueOf(orderRs.getTimestamp("created_at")));
            row.put("items", orderRs.getString("items"));

            dbOrders.add(row);
        }
    }

}catch(Exception e){
    out.println("<div style='color:red;'>Load Order Error: " + e.getMessage() + "</div>");
}finally{
    try{ if(orderRs != null) orderRs.close(); }catch(Exception e){}
    try{ if(orderPs != null) orderPs.close(); }catch(Exception e){}
    try{ if(loadOrderConn != null) loadOrderConn.close(); }catch(Exception e){}
}

/* =========================
   CALCULATE CASH FLOW
========================= */
double totalIn = 0.0;
double totalOut = 0.0;

for(String tx : transactions){

    String[] tData = tx.split(":");

    if(tData.length >= 3){

        double amt = Double.parseDouble(tData[2]);

        if("IN".equals(tData[0])){
            totalIn += amt;
        }else{
            totalOut += amt;
        }
    }
}

double netBalance = totalIn - totalOut;
%>

<%@ include file="header.jsp" %>

<style>
.admin-page{
    width:92%;
    margin:35px auto;
    color:#111;
}

.admin-hero{
    background:#111;
    color:white;
    border-radius:22px;
    padding:35px;
    margin-bottom:25px;
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:20px;
}

.admin-hero h1{
    margin:0 0 8px;
    font-size:32px;
}

.admin-hero p{
    margin:0;
    color:#ddd;
}

.admin-pill{
    background:white;
    color:#111;
    padding:12px 18px;
    border-radius:999px;
    font-weight:800;
    white-space:nowrap;
}

.admin-stats{
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(180px,1fr));
    gap:18px;
    margin-bottom:25px;
}

.stat-card{
    background:white;
    border:1px solid #e5e5e5;
    border-radius:18px;
    padding:22px;
    box-shadow:0 8px 25px rgba(0,0,0,.05);
}

.stat-card small{
    color:#777;
    font-weight:700;
    text-transform:uppercase;
    letter-spacing:.5px;
}

.stat-card h2{
    margin:10px 0 0;
    font-size:24px;
}

.admin-grid{
    display:grid;
    grid-template-columns:1.3fr .9fr;
    gap:24px;
    align-items:start;
}

.admin-stack{
    display:flex;
    flex-direction:column;
    gap:24px;
}

.admin-card-new{
    background:white;
    border:1px solid #e6e6e6;
    border-radius:22px;
    padding:25px;
    box-shadow:0 8px 25px rgba(0,0,0,.05);
}

.admin-card-new h2{
    margin:0 0 18px;
    font-size:22px;
}

.admin-form-new{
    display:grid;
    grid-template-columns:repeat(2,1fr);
    gap:12px;
    margin-bottom:20px;
}

.admin-form-new input,
.admin-form-new select{
    width:100%;
    padding:14px;
    border:1px solid #ddd;
    border-radius:12px;
    background:white;
    font-size:14px;
}

.admin-form-new .full{
    grid-column:1 / -1;
}

.admin-btn-new{
    border:none;
    background:#111;
    color:white;
    padding:12px 16px;
    border-radius:12px;
    font-weight:800;
    cursor:pointer;
}

.admin-btn-new.light{
    background:#f3f3f3;
    color:#111;
    border:1px solid #ddd;
}

.admin-btn-new.danger{
    background:#111;
    color:white;
}

.admin-btn-new:hover{
    opacity:.85;
}

.table-wrap{
    overflow-x:auto;
}

.admin-table-new{
    width:100%;
    border-collapse:collapse;
    min-width:650px;
}

.admin-table-new th{
    background:#f2f2f2;
    color:#111;
    text-align:left;
    padding:14px;
    font-size:13px;
    text-transform:uppercase;
}

.admin-table-new td{
    padding:16px 14px;
    border-bottom:1px solid #eee;
    vertical-align:middle;
}

.admin-table-new tr:hover{
    background:#fafafa;
}

.item-name-cell{
    font-weight:800;
}

.badge-new{
    display:inline-block;
    padding:7px 12px;
    border-radius:999px;
    font-size:12px;
    font-weight:900;
    background:#eee;
    color:#111;
    text-transform:uppercase;
}

.badge-new.dark{
    background:#111;
    color:white;
}

.action-row{
    display:flex;
    gap:8px;
    flex-wrap:wrap;
}

.finance-box{
    display:grid;
    grid-template-columns:repeat(3,1fr);
    gap:12px;
    margin:10px 0 18px;
}

.finance-mini{
    background:#f7f7f7;
    border:1px solid #e5e5e5;
    border-radius:15px;
    padding:16px;
    text-align:center;
    font-weight:900;
}

.finance-mini small{
    display:block;
    color:#777;
    margin-bottom:5px;
}

.status-form select{
    padding:10px;
    border:1px solid #ddd;
    border-radius:10px;
    background:white;
}

.admin-note{
    color:#777;
    font-size:14px;
    margin-top:-8px;
    margin-bottom:18px;
}

@media(max-width:1000px){
    .admin-grid{
        grid-template-columns:1fr;
    }

    .admin-hero{
        flex-direction:column;
        align-items:flex-start;
    }
}

@media(max-width:650px){
    .admin-form-new{
        grid-template-columns:1fr;
    }

    .finance-box{
        grid-template-columns:1fr;
    }
}
</style>

<div class="admin-page">

    <div class="admin-hero">

        <div>
            <h1>Admin Dashboard</h1>
            <p>Manage menu, stock, orders, cash flow and promo codes.</p>
        </div>

        <div class="admin-pill">
            Jitter & Joy Admin
        </div>

    </div>

    <div class="admin-stats">

        <div class="stat-card">
            <small>Total In</small>
            <h2>RM <%= String.format("%.2f", totalIn) %></h2>
        </div>

        <div class="stat-card">
            <small>Total Out</small>
            <h2>RM <%= String.format("%.2f", totalOut) %></h2>
        </div>

        <div class="stat-card">
            <small>Net Balance</small>
            <h2>RM <%= String.format("%.2f", netBalance) %></h2>
        </div>

        <div class="stat-card">
            <small>Customer Orders</small>
            <h2><%= dbOrders.size() %></h2>
        </div>

    </div>

    <div class="admin-grid">

        <div class="admin-stack">

            <!-- MANAGE MENU -->
            <div class="admin-card-new">

                <h2>Manage Menu & Stock</h2>

                <form action="admin.jsp" method="POST" class="admin-form-new">

                    <input type="hidden" name="menuAction" value="add">

                    <input name="itemName" placeholder="Item Name" required>

                    <input name="price" type="number" step="0.01" placeholder="Price (RM)" required>

                    <input name="image" placeholder="Image file name e.g latte.jpg">

                    <select name="category" required>
                        <option value="">Category</option>
                        <option value="hot">Hot</option>
                        <option value="cold">Cold</option>
                        <option value="frappe">Frappe</option>
                        <option value="pastry">Pastry</option>
                        <option value="cake">Cake</option>
                    </select>

                    <input name="description" class="full" placeholder="Description">

                    <button type="submit" class="admin-btn-new full">
                        Add Menu Item
                    </button>

                </form>

                <div class="table-wrap">

                    <table class="admin-table-new">

                        <tr>
                            <th>Item</th>
                            <th>Price</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>

                        <%
                        Connection menuLoadConn = null;
                        PreparedStatement menuLoadPs = null;
                        ResultSet menuRs = null;

                        try{
                            menuLoadConn = DBConnection.getConnection();

                            if(menuLoadConn == null){
                        %>

                        <tr>
                            <td colspan="5" style="text-align:center; color:red;">
                                Database connection failed.
                            </td>
                        </tr>

                        <%
                            }else{

                                menuLoadPs = menuLoadConn.prepareStatement(
                                    "SELECT id, item_name, price, category, status FROM menu ORDER BY category, item_name"
                                );

                                menuRs = menuLoadPs.executeQuery();

                                boolean hasMenu = false;

                                while(menuRs.next()){

                                    hasMenu = true;

                                    int id = menuRs.getInt("id");
                                    String name = menuRs.getString("item_name");
                                    double price = menuRs.getDouble("price");
                                    String category = menuRs.getString("category");
                                    String stockStatus = menuRs.getString("status");
                        %>

                        <tr>
                            <td class="item-name-cell"><%= name %></td>

                            <td>RM <%= String.format("%.2f", price) %></td>

                            <td><%= category %></td>

                            <td>
                                <span class="badge-new <%= "Available".equalsIgnoreCase(stockStatus) ? "" : "dark" %>">
                                    <%= stockStatus %>
                                </span>
                            </td>

                            <td>
                                <div class="action-row">

                                    <form action="admin.jsp" method="POST">

                                        <input type="hidden" name="menuAction" value="toggle">
                                        <input type="hidden" name="menuId" value="<%= id %>">
                                        <input type="hidden" name="currentStatus" value="<%= stockStatus %>">

                                        <button type="submit" class="admin-btn-new light">
                                            <%= "Available".equalsIgnoreCase(stockStatus) ? "Set Out" : "Set Available" %>
                                        </button>

                                    </form>

                                    <form action="admin.jsp" method="POST" onsubmit="return confirm('Delete this item?')">

                                        <input type="hidden" name="menuAction" value="delete">
                                        <input type="hidden" name="menuId" value="<%= id %>">

                                        <button type="submit" class="admin-btn-new danger">
                                            Delete
                                        </button>

                                    </form>

                                </div>
                            </td>

                        </tr>

                        <%
                                }

                                if(!hasMenu){
                        %>

                        <tr>
                            <td colspan="5" style="text-align:center;">
                                No menu item found.
                            </td>
                        </tr>

                        <%
                                }
                            }

                        }catch(Exception e){
                        %>

                        <tr>
                            <td colspan="5" style="text-align:center; color:red;">
                                Menu Load Error: <%= e.getMessage() %>
                            </td>
                        </tr>

                        <%
                        }finally{
                            try{ if(menuRs != null) menuRs.close(); }catch(Exception e){}
                            try{ if(menuLoadPs != null) menuLoadPs.close(); }catch(Exception e){}
                            try{ if(menuLoadConn != null) menuLoadConn.close(); }catch(Exception e){}
                        }
                        %>

                    </table>

                </div>

            </div>

            <!-- CUSTOMER ORDERS -->
            <div class="admin-card-new">

                <h2>Manage Customer Orders</h2>

                <p class="admin-note">
                    Loaded from MySQL orders table.
                </p>

                <div class="table-wrap">

                    <table class="admin-table-new">

                        <tr>
                            <th>Order ID</th>
                            <th>Items</th>
                            <th>Total</th>
                            <th>Status</th>
                            <th>Date</th>
                            <th>Action</th>
                        </tr>

                        <%
                        if(dbOrders.isEmpty()){
                        %>

                        <tr>
                            <td colspan="6" style="text-align:center;">
                                No customer order found.
                            </td>
                        </tr>

                        <%
                        }else{

                            for(Map<String, String> row : dbOrders){

                                String oid = row.get("order_id");
                                String orderStatus = row.get("status");
                        %>

                        <tr>
                            <td class="item-name-cell"><%= oid %></td>

                            <td><%= row.get("items") %></td>

                            <td>RM <%= row.get("total") %></td>

                            <td>
                                <span class="badge-new dark">
                                    <%= orderStatus %>
                                </span>
                            </td>

                            <td><%= row.get("created_at") %></td>

                            <td>
                                <div class="action-row">

                                    <form method="post" action="admin.jsp" class="status-form">

                                        <input type="hidden" name="updateOrderId" value="<%= oid %>">

                                        <select name="newStatus" onchange="this.form.submit()">
                                            <option value="Pending" <%= "Pending".equalsIgnoreCase(orderStatus) ? "selected" : "" %>>Pending</option>
                                            <option value="Preparing" <%= "Preparing".equalsIgnoreCase(orderStatus) ? "selected" : "" %>>Preparing</option>
                                            <option value="Ready to Pickup" <%= "Ready to Pickup".equalsIgnoreCase(orderStatus) ? "selected" : "" %>>Ready</option>
                                            <option value="Complete" <%= "Complete".equalsIgnoreCase(orderStatus) ? "selected" : "" %>>Complete</option>
                                            <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(orderStatus) ? "selected" : "" %>>Cancelled</option>
                                        </select>

                                    </form>

                                    <form method="post" action="admin.jsp" onsubmit="return confirm('Cancel this order?')">

                                        <input type="hidden" name="cancelOrderId" value="<%= oid %>">

                                        <button type="submit" class="admin-btn-new danger">
                                            Cancel
                                        </button>

                                    </form>

                                </div>
                            </td>
                        </tr>

                        <%
                            }
                        }
                        %>

                    </table>

                </div>

            </div>

        </div>

        <div class="admin-stack">

            <!-- CASH FLOW -->
            <div class="admin-card-new">

                <h2>Cash Flow</h2>

                <form action="admin.jsp" method="POST" class="admin-form-new">

                    <select name="txType" required>
                        <option value="IN">Duit Masuk (IN)</option>
                        <option value="OUT">Duit Keluar (OUT)</option>
                    </select>

                    <input name="txAmount" type="number" step="0.01" placeholder="Amount (RM)" required>

                    <input name="txDesc" class="full" placeholder="Description (e.g. Sales, Bills)" required>

                    <button type="submit" class="admin-btn-new full">
                        Record Transaction
                    </button>

                </form>

                <div class="finance-box">

                    <div class="finance-mini">
                        <small>In</small>
                        RM <%= String.format("%.2f", totalIn) %>
                    </div>

                    <div class="finance-mini">
                        <small>Out</small>
                        RM <%= String.format("%.2f", totalOut) %>
                    </div>

                    <div class="finance-mini">
                        <small>Net</small>
                        RM <%= String.format("%.2f", netBalance) %>
                    </div>

                </div>

                <div class="table-wrap">

                    <table class="admin-table-new">

                        <tr>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Amount</th>
                            <th>Action</th>
                        </tr>

                        <%
                        if(transactions.isEmpty()){
                        %>

                        <tr>
                            <td colspan="4" style="text-align:center;">
                                No transaction record.
                            </td>
                        </tr>

                        <%
                        }else{

                            for(int i=0; i<transactions.size(); i++){

                                String[] tData = transactions.get(i).split(":");
                                String type = tData[0];
                                String desc = tData[1];
                                double amt = Double.parseDouble(tData[2]);
                        %>

                        <tr>
                            <td>
                                <span class="badge-new <%= "OUT".equals(type) ? "dark" : "" %>">
                                    <%= type %>
                                </span>
                            </td>

                            <td><%= desc %></td>

                            <td>
                                <%= type.equals("IN") ? "+" : "-" %> RM <%= String.format("%.2f", amt) %>
                            </td>

                            <td>
                                <a href="admin.jsp?delTx=<%= i %>" onclick="return confirm('Delete this record?')">
                                    <button type="button" class="admin-btn-new danger">
                                        Delete
                                    </button>
                                </a>
                            </td>
                        </tr>

                        <%
                            }
                        }
                        %>

                    </table>

                </div>

            </div>

            <!-- PROMO -->
            <div class="admin-card-new">

                <h2>Manage Promo</h2>

                <form action="admin.jsp" method="POST" class="admin-form-new">

                    <input name="promoCode" placeholder="Promo Code" required>

                    <select name="promoType" required>
                        <option value="PERCENT">Percentage (%)</option>
                        <option value="FIXED">Fixed Amount (RM)</option>
                    </select>

                    <input name="promoValue" type="number" step="0.01" placeholder="Value" required>

                    <input name="promoDesc" class="full" placeholder="Description" required>

                    <button type="submit" class="admin-btn-new full">
                        Add Promo
                    </button>

                </form>

                <div class="table-wrap">

                    <table class="admin-table-new">

                        <tr>
                            <th>Code</th>
                            <th>Type</th>
                            <th>Value</th>
                            <th>Action</th>
                        </tr>

                        <%
                        if(promos.isEmpty()){
                        %>

                        <tr>
                            <td colspan="4" style="text-align:center;">
                                No promo code added.
                            </td>
                        </tr>

                        <%
                        }else{

                            for(int i=0; i<promos.size(); i++){

                                String[] pData = promos.get(i).split(":", 4);

                                String code = pData.length > 0 ? pData[0] : "";
                                String type = pData.length > 1 ? pData[1] : "FIXED";
                                double value = pData.length > 2 ? Double.parseDouble(pData[2]) : 0.0;
                        %>

                        <tr>
                            <td class="item-name-cell"><%= code %></td>

                            <td>
                                <span class="badge-new">
                                    <%= type.equals("PERCENT") ? "Percent" : "Fixed" %>
                                </span>
                            </td>

                            <td>
                                <%= type.equals("PERCENT") ? String.format("%.0f%%", value) : "RM " + String.format("%.2f", value) %>
                            </td>

                            <td>
                                <a href="admin.jsp?delPromo=<%= i %>" onclick="return confirm('Delete this promo?')">
                                    <button type="button" class="admin-btn-new danger">
                                        Delete
                                    </button>
                                </a>
                            </td>
                        </tr>

                        <%
                            }
                        }
                        %>

                    </table>

                </div>

            </div>

        </div>

    </div>

</div>

<%@ include file="footer.jsp" %>
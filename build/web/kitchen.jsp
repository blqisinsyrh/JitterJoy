kitchen.jsp
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.connection.DBConnection" %>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="style.css">

<%
/* =========================================================================
   KAWALAN AKSES (Hanya Staf Dapur / Admin sahaja boleh masuk)
   ========================================================================= */
String role = (String) session.getAttribute("role");
if(role == null || (!role.equalsIgnoreCase("admin") && !role.equalsIgnoreCase("staff") && !role.equalsIgnoreCase("kitchen"))){
    response.sendRedirect("login.jsp?msg=unauthorized");
    return;
}

Connection conn = null;
String updateOrderId = request.getParameter("updateOrderId");
String newStatus = request.getParameter("newStatus");

/* =========================================================================
   PROSES KEMAS KINI STATUS OLEH DAPUR (Melalui Dropdown)
   ========================================================================= */
if(updateOrderId != null && newStatus != null){
    try {
        conn = DBConnection.getConnection();
        PreparedStatement psUpdate = conn.prepareStatement(
            "UPDATE orders SET status = ? WHERE order_id = ?"
        );
        psUpdate.setString(1, newStatus);
        psUpdate.setString(2, updateOrderId);
        psUpdate.executeUpdate();
        psUpdate.close();
        
        // Refresh halaman untuk melihat perubahan terkini
        response.sendRedirect("kitchen.jsp");
        return;
    } catch(Exception e) {
        out.println("<pre style='color:red;'>ERROR UPDATE: " + e.getMessage() + "</pre>");
    } finally {
        if(conn != null) try { conn.close(); } catch(Exception e){}
    }
}

/* =========================================================================
   AMBIL DATA PESANAN AKTIF DARI DATABASE (Mengikut Kes-Sensitif Selamat)
   ========================================================================= */
List<Map<String, Object>> activeOrders = new ArrayList<>();

try {
    conn = DBConnection.getConnection();
    
    // Ambil order yang belum selesai sahaja (Pending & Preparing)
    String sqlOrders = "SELECT order_id, total, status FROM orders WHERE LOWER(status) IN ('pending', 'preparing') ORDER BY order_id ASC";
    PreparedStatement psOrders = conn.prepareStatement(sqlOrders);
    ResultSet rsOrders = psOrders.executeQuery();
    
    while(rsOrders.next()){
        Map<String, Object> orderMap = new HashMap<>();
        String oid = rsOrders.getString("order_id");
        orderMap.put("order_id", oid);
        orderMap.put("status", rsOrders.getString("status"));
        
        List<String[]> itemsList = new ArrayList<>();
        String sqlItems = "SELECT item_name, qty, size, sugar, note FROM order_items WHERE order_id = ?";
        PreparedStatement psItems = conn.prepareStatement(sqlItems);
        psItems.setString(1, oid);
        ResultSet rsItems = psItems.executeQuery();
        
        while(rsItems.next()){
            itemsList.add(new String[]{
                rsItems.getString("item_name"),
                String.valueOf(rsItems.getInt("qty")),
                rsItems.getString("size"),
                rsItems.getString("sugar"),
                rsItems.getString("note")
            });
        }
        rsItems.close();
        psItems.close();
        
        orderMap.put("items", itemsList);
        activeOrders.add(orderMap);
    }
    
    rsOrders.close();
    psOrders.close();
} catch(Exception e) {
    out.println("<pre style='color:red;'>ERROR FETCH: " + e.getMessage() + "</pre>");
} finally {
    if(conn != null) try { conn.close(); } catch(Exception e){}
}
%>

<style>
body {
    background: #fdfaf5;
    font-family: 'Segoe UI', Arial, sans-serif;
}

.kitchen-container {
    max-width: 1200px;
    margin: 40px auto;
    padding: 0 20px;
}

.kitchen-title {
    color: #5b3512;
    border-bottom: 3px solid #9c6b3f;
    padding-bottom: 10px;
    margin-bottom: 30px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.refresh-text {
    font-size: 14px;
    color: #6f4725;
    font-weight: normal;
}

/* KITCHEN GRID */
.kitchen-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
    gap: 25px;
}

/* ORDER CARD */
.order-card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 6px 18px rgba(91,53,18,0.06);
    border: 1px solid #f2ece7;
    display: flex;
    flex-direction: column;
    overflow: hidden;
}

.card-header {
    padding: 15px 20px;
    color: white;
    font-weight: bold;
    display: flex;
    justify-content: space-between;
    align-items: center;
    background: #8b5e34; /* Coklat Utama */
}

/* Membezakan ton warna berdasarkan status */
.header-preparing { background: #6f4725; } /* Coklat gelap sedikit untuk status memasak */

.card-body {
    padding: 20px;
    flex-grow: 1;
}

.item-row {
    padding: 10px 0;
    border-bottom: 1px dashed #f2ece7;
}

.item-main {
    display: flex;
    justify-content: space-between;
    font-weight: bold;
    font-size: 16px;
    color: #333;
}

.item-customs {
    font-size: 13px;
    color: #666;
    margin-top: 4px;
    padding-left: 10px;
}

.note-box {
    background: #fff3cd;
    color: #856404;
    padding: 6px 10px;
    border-radius: 6px;
    font-size: 12px;
    margin-top: 5px;
    border-left: 3px solid #ffeeba;
}

.card-footer {
    padding: 15px 20px;
    background: #faf8f5;
    border-top: 1px solid #f2ece7;
    text-align: center;
}

/* STYLE DROPDOWN */
.select-status {
    width: 100%;
    padding: 10px 12px;
    border: 2px solid #9c6b3f;
    border-radius: 8px;
    font-size: 14px;
    font-weight: bold;
    color: #5b3512;
    background-color: white;
    cursor: pointer;
    outline: none;
    transition: 0.2s;
}

.select-status:focus {
    border-color: #6f4725;
    box-shadow: 0 0 5px rgba(111,71,37,0.3);
}

.no-orders {
    grid-column: span 3;
    text-align: center;
    padding: 60px;
    background: white;
    border-radius: 16px;
    color: #6f4725;
    box-shadow: 0 4px 12px rgba(0,0,0,0.05);
    border: 1px solid #f2ece7;
}
</style>

<div class="kitchen-container">

    <h1 class="kitchen-title">
        ? Kitchen Display System (Dapur)
        <span class="refresh-text">? Auto-aligned with Database</span>
    </h1>

    <div class="kitchen-grid">
        <%
        if(!activeOrders.isEmpty()){
            for(Map<String, Object> order : activeOrders){
                String orderId = (String) order.get("order_id");
                String status = (String) order.get("status");
                List<String[]> items = (List<String[]>) order.get("items");
                
                String headerClass = status.equalsIgnoreCase("Preparing") ? "header-preparing" : "";
        %>
        
        <div class="order-card">
            
            <div class="card-header <%= headerClass %>">
                <span><%= orderId %></span>
                <span><%= status.toUpperCase() %></span>
            </div>
            
            <div class="card-body">
                <%
                for(String[] item : items){
                    String itemName = item[0];
                    String qty = item[1];
                    String size = item[2];
                    String sugar = item[3];
                    String note = item[4];
                %>
                <div class="item-row">
                    <div class="item-main">
                        <span>? <%= itemName %></span>
                        <span style="color: #9c6b3f;">x<%= qty %></span>
                    </div>
                    
                    <% if(size != null && !size.equals("") && !size.equals("-")) { %>
                        <div class="item-customs">? Saiz: <%= size %></div>
                    <% } %>
                    
                    <% if(sugar != null && !sugar.equals("") && !sugar.equals("-")) { %>
                        <div class="item-customs">? Gula: <%= sugar %></div>
                    <% } %>
                    
                    <% if(note != null && !note.trim().equals("")) { %>
                        <div class="note-box">? <b>Nota:</b> "<%= note %>"</div>
                    <% } %>
                </div>
                <% } %>
            </div>
            
            <div class="card-footer">
                <form method="POST" action="kitchen.jsp" style="margin:0;">
                    <input type="hidden" name="updateOrderId" value="<%= orderId %>">
                    <select name="newStatus" class="select-status" onchange="if(this.value!='') { if(this.value=='Ready to Pickup' ? confirm('Adakah hidangan <%= orderId %> sudah siap sepenuhnya?') : true) { this.form.submit(); } else { this.value='<%= status %>'; } }">
                        <option value="Pending" <%= status.equalsIgnoreCase("Pending") ? "selected" : "" %>>? Pending (Menunggu)</option>
                        <option value="Preparing" <%= status.equalsIgnoreCase("Preparing") ? "selected" : "" %>>??? Preparing (Memasak)</option>
                        <option value="Ready to Pickup">? Ready to Pickup (Siap)</option>
                        <option value="Complete">? Complete (Selesai Ambil)</option>
                    </select>
                </form>
            </div>
            
        </div>
        
        <%
            }
        } else {
        %>
            <div class="no-orders">
                <h2>? Tiada Pesanan Aktif</h2>
                <p>Semua pesanan di dapur telah diselesaikan buat masa ini.</p>
            </div>
        <%
        }
        %>
    </div>

</div>

<%@ include file="footer.jsp" %>

```
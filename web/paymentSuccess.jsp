<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="com.connection.DBConnection" %>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="style.css">

<%
/* =========================
   ORDER ID SAFE
========================= */
String orderId = request.getParameter("orderId");

if(orderId == null || orderId.trim().equals("")){
    orderId = (String) session.getAttribute("lastOrderId");
}

if(orderId == null || orderId.trim().equals("")){
    orderId = (String) session.getAttribute("orderId");
}

if(orderId != null && !orderId.trim().equals("")){
    session.setAttribute("lastOrderId", orderId);
}

/* =========================
   RECEIPT DATA
========================= */
List<String[]> receiptData = new ArrayList<>();
Double total = (Double) session.getAttribute("finalTotal");
if(total == null){
    total = 0.0;
}

Connection conn = DBConnection.getConnection();

if(conn != null && orderId != null){
    try{
        PreparedStatement psTotal = conn.prepareStatement(
            "SELECT total FROM orders WHERE order_id=?"
        );
        psTotal.setString(1, orderId);
        ResultSet rsTotal = psTotal.executeQuery();
        if(rsTotal.next()){
            total = rsTotal.getDouble("total");
        }
        rsTotal.close();
        psTotal.close();

        PreparedStatement ps = conn.prepareStatement(
            "SELECT item_name, qty, price, size, sugar, note FROM order_items WHERE order_id=?"
        );

        ps.setString(1, orderId);
        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            receiptData.add(new String[]{
                rs.getString("item_name"),
                String.valueOf(rs.getInt("qty")),
                String.valueOf(rs.getDouble("price")),
                rs.getString("size"),
                rs.getString("sugar"),
                rs.getString("note")
            });
        }

        rs.close();
        ps.close();
        conn.close();

    }catch(Exception e){
        out.println("<div class='error-message'>Receipt Error: " + e.getMessage() + "</div>");
    }
}

java.util.Date now = new java.util.Date();
SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
SimpleDateFormat tf = new SimpleDateFormat("HH:mm:ss");
String receiptNo = "RCPT" + System.currentTimeMillis();
%>

<div class="payment-success-page">

    <div class="success-receipt-card">

        <div class="success-header-v2">
            <div class="success-icon"></div>
            <p class="eyebrow">Payment Completed</p>
            <h1>Payment Successful</h1>
            <p>Your order has been received and will be prepared for pickup.</p>
        </div>

        <div class="receipt-meta-grid">
            <div>
                <span>Receipt No</span>
                <b><%= receiptNo %></b>
            </div>
            <div>
                <span>Order ID</span>
                <b><%= orderId %></b>
            </div>
            <div>
                <span>Date</span>
                <b><%= df.format(now) %></b>
            </div>
            <div>
                <span>Time</span>
                <b><%= tf.format(now) %></b>
            </div>
        </div>

        <div class="receipt-list-v2">

            <%
            if(!receiptData.isEmpty()){
                for(String[] item : receiptData){

                    String name = item[0];
                    int qty = 1;
                    double price = 0.0;

                    try{ qty = Integer.parseInt(item[1]); }catch(Exception e){}
                    try{ price = Double.parseDouble(item[2]); }catch(Exception e){}

                    String size = (item.length > 3) ? item[3] : "";
                    String sugar = (item.length > 4) ? item[4] : "";
                    String note = (item.length > 5) ? item[5] : "";
                    double amount = qty * price;
            %>

            <div class="receipt-row-v2">
                <div>
                    <b><%= name %></b>
                    <span><%= qty %> x RM <%= String.format("%.2f", price) %></span>

                    <% if(size != null && !size.trim().equals("") && !size.equals("-")){ %>
                        <small>Option: <%= size %></small>
                    <% } %>

                    <% if(sugar != null && !sugar.trim().equals("") && !sugar.equals("-")){ %>
                        <small>Sugar: <%= sugar %></small>
                    <% } %>

                    <% if(note != null && !note.trim().equals("")){ %>
                        <small>Note: <%= note %></small>
                    <% } %>
                </div>
                <strong>RM <%= String.format("%.2f", amount) %></strong>
            </div>

            <%
                }
            } else {
            %>

            <div class="empty-receipt">No order item found.</div>

            <%
            }
            %>

        </div>

        <div class="receipt-total-v2">
            <span>Total Payment</span>
            <strong>RM <%= String.format("%.2f", total) %></strong>
        </div>

        <p class="success-thanks">Thank you for ordering from Jitter & Joy.</p>

        <div class="success-actions no-print">
            <button type="button" onclick="window.print()">Print / Save PDF</button>
            <button type="button" onclick="window.location.href='tracking.jsp?orderId=<%= orderId %>'">Track Order</button>
        </div>

    </div>

</div>

<%@ include file="footer.jsp" %>

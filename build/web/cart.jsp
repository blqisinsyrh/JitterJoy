<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.connection.DBConnection" %>
<%@ include file="header.jsp" %>

<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public boolean isDrinkCategory(String category) {
        if(category == null) return false;
        category = category.toLowerCase().trim();
        return category.equals("hot") || category.equals("cold") || category.equals("iced") || category.equals("frappe");
    }
%>

<%
String success = request.getParameter("success");
String dbMessage = "";

/* ==========================================================
   LOAD MENU DATA FROM MYSQL TABLE: menu
   id, item_name, price, image, category, description, status
   ========================================================== */
Map<String, String[]> menuMap = new HashMap<String, String[]>();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = DBConnection.getConnection();

    if(conn == null){
        dbMessage = "Database connection failed. Please check MySQL port 3307 and database JJ.";
    } else {
        ps = conn.prepareStatement("SELECT item_name, price, image, category FROM menu WHERE status='Available'");
        rs = ps.executeQuery();

        while(rs.next()){
            String name = rs.getString("item_name");
            String priceDb = String.format("%.2f", rs.getDouble("price"));
            String image = rs.getString("image");
            String category = rs.getString("category");

            if(image == null || image.trim().isEmpty()) image = "default.jpeg";
            if(category == null) category = "";

            menuMap.put(name, new String[]{priceDb, image, category.toLowerCase().trim()});
        }
    }
} catch(Exception e){
    dbMessage = "Ralat Database: " + e.getMessage();
} finally {
    if(rs != null) try { rs.close(); } catch(Exception e) {}
    if(ps != null) try { ps.close(); } catch(Exception e) {}
    if(conn != null) try { conn.close(); } catch(Exception e) {}
}

/* =========================
   SAFE CART IN SESSION
   Format: item:size:price:qty:note:sugar:category
========================= */
List<String> cart = (List<String>) session.getAttribute("cart");
if(cart == null){
    cart = new ArrayList<String>();
}

/* =========================
   ADD TO CART ACTION
========================= */
String item = request.getParameter("item");
String price = request.getParameter("price");
String size = request.getParameter("size");
String note = request.getParameter("note");
String sugar = request.getParameter("sugar");
String categoryParam = request.getParameter("category");

if(note == null) note = "";
if(sugar == null) sugar = "";
if(size == null || size.equals("")) size = "-";
if(categoryParam == null) categoryParam = "";

// If menu table contains the item, use the database price/category as source of truth.
if(item != null && menuMap.containsKey(item)){
    price = menuMap.get(item)[0];
    if(categoryParam.trim().isEmpty()){
        categoryParam = menuMap.get(item)[2];
    }
}

if(item != null && price != null){
    boolean found = false;

    for(int i=0; i<cart.size(); i++){
        String[] d = cart.get(i).split(":", -1);
        String name = d.length > 0 ? d[0] : "";
        String sizeVal = d.length > 1 ? d[1] : "-";
        String priceVal = d.length > 2 ? d[2] : "0";
        String qtyVal = d.length > 3 ? d[3] : "1";
        String noteVal = d.length > 4 ? d[4] : "";
        String sugarVal = d.length > 5 ? d[5] : "";
        String catVal = d.length > 6 ? d[6] : "";

        int qty = 1;
        try { qty = Integer.parseInt(qtyVal); } catch(Exception e) { qty = 1; }

        if(name.equals(item) && sizeVal.equals(size) && noteVal.equals(note) && sugarVal.equals(sugar)){
            qty++;
            cart.set(i, name + ":" + sizeVal + ":" + priceVal + ":" + qty + ":" + noteVal + ":" + sugarVal + ":" + catVal);
            found = true;
            break;
        }
    }

    if(!found){
        cart.add(item + ":" + size + ":" + price + ":1:" + note + ":" + sugar + ":" + categoryParam);
    }
}

/* =========================
   REMOVE ITEM ACTION
========================= */
String remove = request.getParameter("remove");
if(remove != null){
    try{
        int i = Integer.parseInt(remove);
        if(i >= 0 && i < cart.size()){
            cart.remove(i);
        }
    }catch(Exception e){}
}

/* =========================
   QTY UPDATE ACTION
========================= */
String action = request.getParameter("action");
String indexStr = request.getParameter("index");

if(action != null && indexStr != null){
    try{
        int i = Integer.parseInt(indexStr);
        String[] d = cart.get(i).split(":", -1);
        String name = d.length > 0 ? d[0] : "";
        String sizeVal = d.length > 1 ? d[1] : "-";
        String priceVal = d.length > 2 ? d[2] : "0";
        int qty = d.length > 3 ? Integer.parseInt(d[3]) : 1;
        String noteVal = d.length > 4 ? d[4] : "";
        String sugarVal = d.length > 5 ? d[5] : "";
        String catVal = d.length > 6 ? d[6] : "";

        if(action.equals("add")) qty++;
        else if(action.equals("minus")) qty--;

        if(qty <= 0){
            cart.remove(i);
        }else{
            cart.set(i, name + ":" + sizeVal + ":" + priceVal + ":" + qty + ":" + noteVal + ":" + sugarVal + ":" + catVal);
        }
    }catch(Exception e){}
}

/* =========================
   UPDATE NOTE / SUGAR
========================= */
String editIndex = request.getParameter("editIndex");
String newSugar = request.getParameter("newSugar");
String newNote = request.getParameter("newNote");

if(editIndex != null){
    try{
        int i = Integer.parseInt(editIndex);
        String[] d = cart.get(i).split(":", -1);
        String name = d.length > 0 ? d[0] : "";
        String sizeVal = d.length > 1 ? d[1] : "-";
        String priceVal = d.length > 2 ? d[2] : "0";
        String qtyVal = d.length > 3 ? d[3] : "1";
        String oldNote = d.length > 4 ? d[4] : "";
        String oldSugar = d.length > 5 ? d[5] : "";
        String catVal = d.length > 6 ? d[6] : "";

        if(menuMap.containsKey(name)){
            priceVal = menuMap.get(name)[0];
            if(catVal.trim().isEmpty()) catVal = menuMap.get(name)[2];
        }

        if(newSugar == null) newSugar = oldSugar;
        if(newNote == null) newNote = oldNote;

        cart.set(i, name + ":" + sizeVal + ":" + priceVal + ":" + qtyVal + ":" + newNote + ":" + newSugar + ":" + catVal);
    }catch(Exception e){}
}

session.setAttribute("cart", cart);

/* =========================
   CALCULATE TOTAL
========================= */
double grandTotal = 0.0;
for(int i=0; i<cart.size(); i++){
    String[] d = cart.get(i).split(":", -1);
    double priceVal = 0.0;
    int qtyVal = 1;

    try { priceVal = Double.parseDouble(d.length > 2 ? d[2] : "0"); } catch(Exception e) { priceVal = 0.0; }
    try { qtyVal = Integer.parseInt(d.length > 3 ? d[3] : "1"); } catch(Exception e) { qtyVal = 1; }

    grandTotal += priceVal * qtyVal;
}

session.setAttribute("total", grandTotal);
if(session.getAttribute("discount") == null){
    session.setAttribute("discount", 0.0);
}
%>

<!DOCTYPE html>
<html>
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<title>Cart | Jitter & Joy</title>

<style>

body{
    background:#f8f7f4;
}

.cart-container{

    width:95%;

    margin:30px auto;

    display:grid;

    grid-template-columns:2fr 1fr;

    gap:25px;
}

/* LEFT */

.cart-items{

    background:white;

    border-radius:15px;

    padding:25px;

    box-shadow:
    0 2px 15px rgba(0,0,0,.08);
}

.cart-title{

    font-size:28px;

    color:#4E342E;

    margin-bottom:25px;
}

.item{

    display:flex;

    justify-content:space-between;

    align-items:center;

    gap:18px;

    padding:20px 0;

    border-bottom:1px solid #eee;
}

.item-info{

    display:flex;

    gap:15px;

    align-items:center;

    min-width:240px;
}

.item-info img{

    width:90px;
    height:90px;

    object-fit:cover;

    border-radius:12px;
}

.item-name{
    font-weight:600;
    margin-bottom:5px;
}

.item-size{
    color:#777;
    font-size:14px;
}

.item-custom{
    min-width:260px;
    max-width:320px;
}

.item-custom label{
    font-size:12px;
    font-weight:bold;
    color:#4E342E;
}

.item-custom select,
.item-custom textarea{
    width:100%;
    padding:10px;
    border:1px solid #ddd;
    border-radius:10px;
    margin-top:5px;
    margin-bottom:8px;
    font-family:inherit;
}

.qty{

    display:flex;

    align-items:center;

    gap:10px;
}

.qty a{

    width:35px;
    height:35px;

    border:none;

    border-radius:50%;

    background:#6D4C41;

    color:white;

    cursor:pointer;

    text-decoration:none;

    display:flex;
    justify-content:center;
    align-items:center;
}

.remove{

    background:#dc3545;
    color:white;

    border:none;

    padding:8px 15px;

    border-radius:8px;

    cursor:pointer;
}

.update-btn{
    background:#2e7d4f;
    color:white;
    border:none;
    padding:9px 14px;
    border-radius:8px;
    cursor:pointer;
    font-weight:600;
}

/* RIGHT */

.summary{

    background:white;

    border-radius:15px;

    padding:25px;

    height:fit-content;

    box-shadow:
    0 2px 15px rgba(0,0,0,.08);
}

.summary h2{

    color:#4E342E;

    margin-bottom:20px;
}

.row{

    display:flex;

    justify-content:space-between;

    margin-bottom:15px;
}

.mode{

    margin-top:20px;
}

.mode label{

    display:block;

    margin-bottom:10px;
}

.voucher{

    margin-top:20px;
}

.voucher input{

    width:100%;

    padding:12px;

    border:1px solid #ddd;

    border-radius:10px;
}

.apply-btn{

    width:100%;

    margin-top:10px;

    border:none;

    background:#6D4C41;

    color:white;

    padding:12px;

    border-radius:10px;

    cursor:pointer;
}

.total{

    margin-top:20px;

    border-top:1px solid #eee;

    padding-top:20px;

    font-size:20px;

    font-weight:bold;
}

.checkout-btn{

    width:100%;

    margin-top:20px;

    border:none;

    background:#4E342E;

    color:white;

    padding:15px;

    border-radius:10px;

    font-size:16px;

    cursor:pointer;
}

.checkout-btn:hover{
    background:#3E2723;
}

.checkout-btn:disabled{
    background:#ccc;
    cursor:not-allowed;
}

.empty{

    text-align:center;

    padding:40px;

    color:#777;
}

.success{
    width:95%;
    margin:25px auto 0;
    background:#e6f4ea;
    color:#2e7d4f;
    padding:12px 18px;
    border-radius:10px;
    font-weight:600;
}

.db-error{
    width:95%;
    margin:25px auto 0;
    background:#fff3cd;
    color:#7a5200;
    padding:12px 18px;
    border-radius:10px;
    font-weight:600;
}

.price-text,
.subtotal-text{
    white-space:nowrap;
    font-weight:600;
    color:#4E342E;
}

@media(max-width:900px){

.cart-container{

grid-template-columns:1fr;

}

.item{
    align-items:flex-start;
    flex-direction:column;
}

.item-custom{
    min-width:100%;
    max-width:100%;
}

}

</style>

</head>

<body>
<%
if(success != null){
%>

<div class="success">

Item Added To Cart

</div>

<%
}
%>

<% if(dbMessage != null && !dbMessage.trim().isEmpty()){ %>
<div class="db-error"><%= h(dbMessage) %></div>
<% } %>

<div class="cart-container">

<!-- CART ITEMS -->

<div class="cart-items">

<h1 class="cart-title">

My Cart

</h1>

<% if(cart.isEmpty()){ %>
    <div class="empty">
        Your cart is empty.
    </div>
<% } else { %>

    <%
    for(int i=0; i<cart.size(); i++){
        String[] d = cart.get(i).split(":", -1);
        String name = d.length > 0 ? d[0] : "";
        String sizeVal = d.length > 1 ? d[1] : "-";
        String priceVal = d.length > 2 ? d[2] : "0";
        int qty = 1;
        String noteVal = d.length > 4 ? d[4] : "";
        String sugarVal = d.length > 5 ? d[5] : "";
        String category = d.length > 6 ? d[6] : "";
        String image = "default.jpeg";

        try { qty = Integer.parseInt(d.length > 3 ? d[3] : "1"); } catch(Exception e) { qty = 1; }

        if(menuMap.containsKey(name)){
            image = menuMap.get(name)[1];
            if(category == null || category.trim().isEmpty()) category = menuMap.get(name)[2];
        }

        double itemPrice = 0.0;
        try { itemPrice = Double.parseDouble(priceVal); } catch(Exception e) { itemPrice = 0.0; }
        double subtotal = itemPrice * qty;
    %>

        <div class="item">

            <div class="item-info">

                <img src="images/<%= h(image) %>" alt="<%= h(name) %>" onerror="this.src='images/default.jpeg'">

                <div>

                    <div class="item-name">
                        <%= h(name) %>
                    </div>

                    <% if(sizeVal != null && !sizeVal.equals("-") && !sizeVal.trim().isEmpty()){ %>
                    <div class="item-size">
                        <%= h(sizeVal) %>
                    </div>
                    <% } %>

                    <% if(sugarVal != null && !sugarVal.trim().isEmpty()){ %>
                    <div class="item-size">
                        <%= h(sugarVal) %>
                    </div>
                    <% } %>

                </div>

            </div>

            <div class="item-custom">
                <form action="cart.jsp" method="post">
                    <input type="hidden" name="editIndex" value="<%= i %>">

                    <% if(isDrinkCategory(category)){ %>
                        <label>Sugar Level:</label>
                        <select name="newSugar">
                            <option value="Normal Sugar" <%= "Normal Sugar".equals(sugarVal)?"selected":"" %>>Normal Sugar</option>
                            <option value="Less Sugar" <%= "Less Sugar".equals(sugarVal)?"selected":"" %>>Less Sugar</option>
                            <option value="Extra Sugar" <%= "Extra Sugar".equals(sugarVal)?"selected":"" %>>Extra Sugar</option>
                            <option value="No Sugar" <%= "No Sugar".equals(sugarVal)?"selected":"" %>>No Sugar</option>
                        </select>
                    <% } %>

                    <label>Special Note:</label>
                    <textarea name="newNote" rows="2" placeholder="E.g. No veggie, extra spicy"><%= h(noteVal) %></textarea>

                    <button type="submit" class="update-btn">
                        Update Note
                    </button>
                </form>
            </div>

            <div class="price-text">
                RM <%= String.format("%.2f", itemPrice) %>
            </div>

            <div class="qty">

                <a href="cart.jsp?action=minus&index=<%= i %>">-</a>

                <span><%= qty %></span>

                <a href="cart.jsp?action=add&index=<%= i %>">+</a>

            </div>

            <div class="subtotal-text">
                RM <%= String.format("%.2f", subtotal) %>
            </div>

            <form action="cart.jsp" method="get">

                <input type="hidden"
                       name="remove"
                       value="<%= i %>">

                <button class="remove" type="submit">
                    Remove
                </button>

            </form>

        </div>

    <% } %>

<% } %>
</div>

<!-- SUMMARY -->

<div class="summary">

<h2>

Order Summary

</h2>

<div class="row">

<span>Subtotal</span>

<span>RM <%= String.format("%.2f", grandTotal) %></span>

</div>

<div class="row">

<span>Discount</span>

<span>- RM <%= String.format("%.2f", ((Double)session.getAttribute("discount"))) %></span>

</div>

<div class="mode">

<label>

<input
 type="radio"
 name="orderMode"
 checked>

Pickup

</label>

<label>

<input
 type="radio"
 name="orderMode">

Dine-In

</label>

</div>

<form action="applyPromo.jsp" method="post" class="voucher">

<input
 type="text"
 name="promo"
 placeholder="Enter Voucher Code">

<button class="apply-btn" type="submit">

Apply Voucher

</button>

</form>

<div class="total">

    <div class="row">

        <span>Total</span>

        <span>RM <%= String.format("%.2f", grandTotal - ((Double)session.getAttribute("discount"))) %></span>

    </div>

</div>

<form action="checkout.jsp">

<button
 type="submit"
 class="checkout-btn"
 <%= cart.isEmpty() ? "disabled" : "" %>>

Proceed To Checkout

</button>

</form>

</div>

</div>

</body>
</html>

<%@ include file="footer.jsp" %>

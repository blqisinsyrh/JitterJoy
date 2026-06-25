<%@ page import="java.util.*" %>
<%@ include file="header.jsp" %>

<link rel="stylesheet" href="style.css">

<%
List<String> cart = (List<String>) session.getAttribute("cart");
if (cart == null) cart = new ArrayList<>();

double total = 0.0;

for (String item : cart) {
    String[] data = item.split(":");
    if (data.length > 1) {
        total += Double.parseDouble(data[1]);
    }
}

session.setAttribute("total", total);

Double discount = (Double) session.getAttribute("discount");
if (discount == null) discount = 0.0;

Double finalTotal = (Double) session.getAttribute("finalTotal");
if (finalTotal == null) {
    finalTotal = total;
}
%>


<div class="card">

    <h2>Checkout</h2>

    <p><b>Subtotal:</b> RM <%= total %></p>
    <p><b>Discount:</b> RM <%= discount %></p>
    <p><b>Total:</b> RM <%= finalTotal %></p>

    <hr>

    <!-- PROMO CODE -->
    <form action="applyPromo.jsp" method="post">
        <label>Promo Code:</label>
        <input type="text" name="promo" placeholder="Enter code (SAVE10)">
        <button class="btn" type="submit">Apply</button>
    </form>

    <hr>

    <!-- PAYMENT FORM -->
    <form action="processPayment.jsp" method="post">

        <input type="hidden" name="total" value="<%= finalTotal %>">

        <div class="payment-option">
            <label>
                <input type="radio" name="method" value="cash" required>
                Cash Payment
            </label>
        </div>

        <div class="payment-option">
            <label>
                <input type="radio" name="method" value="debit">
                Debit Card
            </label>
        </div>

        <div class="payment-option">
            <label>
                <input type="radio" name="method" value="credit">
                Credit Card
            </label>
        </div>

        <div class="payment-option">
            <label>
                <input type="radio" name="method" value="toyyib">
                Online Banking (ToyyibPay)
            </label>
        </div>

        <br>

        <button class="btn" type="submit">Pay Now</button>
    </form>

</div>

<%@ include file="footer.jsp" %>
<%@ page import="java.util.*" %>

<%@ include file="header.jsp" %>

<link rel="stylesheet" href="style.css">

<%
if(session.getAttribute("orderId") == null){
    session.setAttribute("orderId", "OID" + System.currentTimeMillis());
}

/* =========================
   LOGIN CHECK
========================= */
if(session.getAttribute("user") == null){
    response.sendRedirect("login.jsp?msg=loginRequired");
    return;
}

/* =========================
   GET CART
========================= */
List<String> cart = (List<String>) session.getAttribute("cart");

if(cart == null){
    cart = new ArrayList<String>();
}

/* =========================
   CALCULATE SUBTOTAL
========================= */
double subtotal = 0.0;

for(String item : cart){

    String[] data = item.split(":");

    if(data.length >= 4){

        double price = 0.0;
        int qty = 1;

        try{
            price = Double.parseDouble(data[2]);
        }catch(Exception e){
            price = 0.0;
        }

        try{
            qty = Integer.parseInt(data[3]);
        }catch(Exception e){
            qty = 1;
        }

        subtotal += price * qty;
    }
}

session.setAttribute("total", subtotal);

/* =========================
   DISCOUNT SAFE VALUE
========================= */
Double discount = (Double) session.getAttribute("discount");

if(discount == null){
    discount = 0.0;
}

/* =========================
   FINAL TOTAL
========================= */
double finalTotal = subtotal - discount;

if(finalTotal < 0){
    finalTotal = 0.0;
}

session.setAttribute("finalTotal", finalTotal);
%>

<div class="checkout-page">

    <div class="checkout-heading">
        <p class="eyebrow">Order Confirmation</p>
        <h1>Checkout</h1>
        <p>Review your total and choose a payment method.</p>
    </div>

    <div class="checkout-layout-v2">

        <!-- PAYMENT SUMMARY -->
        <div class="checkout-panel summary-panel">

            <h2>Payment Summary</h2>

            <div class="summary-line">
                <span>Subtotal</span>
                <strong>RM <%= String.format("%.2f", subtotal) %></strong>
            </div>

            <div class="summary-line">
                <span>Discount</span>
                <strong>- RM <%= String.format("%.2f", discount) %></strong>
            </div>

            <div class="summary-divider"></div>

            <div class="summary-line total-payment">
                <span>Total Payment</span>
                <strong>RM <%= String.format("%.2f", finalTotal) %></strong>
            </div>

            <div class="checkout-note-box">
                <b>Pickup Only</b>
                <span>Your order will be prepared after payment is completed.</span>
            </div>

        </div>

        <!-- PAYMENT METHOD -->
        <form action="processPayment.jsp" method="post" class="checkout-panel payment-panel">

            <input type="hidden" name="total" value="<%= finalTotal %>">

            <h2>Payment Method</h2>

            <div class="payment-method-title">
                Select Payment Method
            </div>

            <label class="payment-choice">
                <input type="radio" name="method" value="cash" required>
                <span>
                    <b>Cash Payment</b>
                    <small>Pay at the counter during pickup.</small>
                </span>
            </label>

            <label class="payment-choice">
                <input type="radio" name="method" value="toyyib" required>
                <span>
                    <b>Online Banking</b>
                    <small>Pay through ToyyibPay.</small>
                </span>
            </label>

            <button class="checkout-main-btn" type="submit" <%= cart.isEmpty() ? "disabled" : "" %>>
                Pay Now
            </button>

        </form>

    </div>

</div>

<%@ include file="footer.jsp" %>
<%-- 
    Document   : debitPayment
    Created on : 22 Apr 2026, 3:04:09 pm
    Author     : alessa
--%>

<%@ page contentType="text/html" pageEncoding="UTF-8"%>

<%
String total = (String) session.getAttribute("payTotal");

if(total == null){
    total = "0.00";
}

String submit = request.getParameter("submit");

if(submit != null){

    String cardName   = request.getParameter("cardName");
    String cardNumber = request.getParameter("cardNumber");
    String expiry     = request.getParameter("expiry");
    String cvv        = request.getParameter("cvv");

    if(cardName != null && cardNumber != null &&
       expiry != null && cvv != null &&
       !cardName.equals("") &&
       !cardNumber.equals("") &&
       !expiry.equals("") &&
       !cvv.equals("")){

        session.setAttribute("cardHolder", cardName);
        session.setAttribute("paymentMethod", "Debit Card");
        session.setAttribute("orderStatus", "Paid (Debit Card)");
        session.setAttribute("paymentAmount", total);

        response.sendRedirect("paymentSuccess.jsp");
        return;
    }
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Debit Card Payment</title>


</head>
<body>

<jsp:include page="header.jsp" />

<div class="container">

    <h2>Debit Card Payment</h2>

    <div class="total">
        Total Amount: RM <%= total %>
    </div>

    <form method="post" action="debitPayment.jsp">

        <label>Card Holder Name</label>
        <input type="text" name="cardName" required>

        <label>Card Number</label>
        <input type="text" name="cardNumber" maxlength="16" placeholder="1234123412341234" required>

        <div class="row">

            <div>
                <label>Expiry Date</label>
                <input type="text" name="expiry" placeholder="MM/YY" required>
            </div>

            <div>
                <label>CVV</label>
                <input type="password" name="cvv" maxlength="3" required>
            </div>

        </div>

        <button type="submit" name="submit">Pay Now</button>

    </form>

    <a href="checkout.jsp" class="back">← Back to Checkout</a>

</div>

</body>
</html>
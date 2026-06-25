<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="java.util.List"%>

<%
/* =========================
   LOAD PROMO LIST
========================= */
List<String> promos = (List<String>) application.getAttribute("promoList");

if(promos == null){
    promos = new ArrayList<String>();
    promos.add("SAVE10:PERCENT:10:Get 10% discount on total payment");
    promos.add("FOOD5:FIXED:5:Get RM5 off instantly");
    application.setAttribute("promoList", promos);
}

/* =========================
   GET PROMO INPUT
========================= */
String code = request.getParameter("promo");

Double total = (Double) session.getAttribute("total");

if(total == null){
    total = (Double) session.getAttribute("finalTotal");
}

if(total == null){
    total = 0.0;
}

double discount = 0.0;
String message = "";

/* =========================
   APPLY PROMO
========================= */
if(code != null){

    String enteredCode = code.trim().toUpperCase();

    if(enteredCode.length() == 0){
        session.setAttribute("promoMessage", "Please enter promo code.");
        response.sendRedirect("checkout.jsp");
        return;
    }

    boolean found = false;

    synchronized(application){

        promos = (List<String>) application.getAttribute("promoList");

        if(promos == null){
            promos = new ArrayList<String>();
        }

        for(int i = 0; i < promos.size(); i++){

            String promo = promos.get(i);
            String[] pData = promo.split(":", 4);

            if(pData.length >= 4 && enteredCode.equalsIgnoreCase(pData[0])){

                found = true;

                String promoCode = pData[0];
                String promoType = pData[1];
                double promoValue = 0.0;

                try{
                    promoValue = Double.parseDouble(pData[2]);
                }catch(Exception e){
                    promoValue = 0.0;
                }

                if("PERCENT".equalsIgnoreCase(promoType)){
                    discount = total * (promoValue / 100.0);
                } else {
                    discount = promoValue;
                }

                if(discount > total){
                    discount = total;
                }

                double finalTotal = total - discount;

                if(finalTotal < 0){
                    finalTotal = 0.0;
                }

                session.setAttribute("discount", discount);
                session.setAttribute("finalTotal", finalTotal);
                session.setAttribute("promoMessage", "Promo " + promoCode + " applied successfully!");
                session.setAttribute("appliedPromo", promoCode);

                /* REMOVE PROMO AFTER USE */
                promos.remove(i);
                application.setAttribute("promoList", promos);

                break;
            }
        }
    }

    if(!found){
        discount = 0.0;
        session.setAttribute("discount", discount);
        session.setAttribute("promoMessage", "Invalid promo code or promo already used.");
    }

    response.sendRedirect("checkout.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Promo Code</title>
<link rel="stylesheet" href="style.css">

<style>
.promo-page{
    width:90%;
    max-width:650px;
    margin:50px auto;
    background:white;
    border:1px solid #e5e5e5;
    border-radius:20px;
    padding:35px;
    box-shadow:0 8px 25px rgba(0,0,0,.05);
}

.promo-page h2{
    margin-bottom:25px;
    color:#111;
}

.promo-box{
    background:#f7f7f7;
    border:1px solid #ddd;
    border-radius:16px;
    padding:20px;
    margin-bottom:15px;
}

.promo-box b{
    font-size:20px;
    color:#111;
}

.promo-box small{
    display:inline-block;
    margin-top:10px;
    font-weight:800;
    color:#111;
}

.promo-apply-form{
    display:flex;
    gap:12px;
    margin-top:25px;
}

.promo-apply-form input{
    flex:1;
    padding:14px;
    border:1px solid #ddd;
    border-radius:12px;
    font-size:15px;
}

.promo-apply-form button,
.back-btn{
    background:#111;
    color:white;
    border:none;
    padding:14px 22px;
    border-radius:12px;
    font-weight:800;
    text-decoration:none;
    cursor:pointer;
}

.back-btn{
    display:inline-block;
    margin-top:15px;
}

.empty-promo{
    background:#f7f7f7;
    border-radius:16px;
    padding:30px;
    text-align:center;
    color:#555;
}

@media(max-width:600px){
    .promo-apply-form{
        flex-direction:column;
    }
}
</style>
</head>

<body>

<jsp:include page="header.jsp" />

<div class="container promo-page">

    <h2>Available Promo Codes</h2>

    <%
    promos = (List<String>) application.getAttribute("promoList");

    if(promos == null || promos.isEmpty()){
    %>

        <div class="empty-promo">
            No promo code available.
        </div>

    <%
    } else {

        for(String promo : promos){

            String[] pData = promo.split(":", 4);

            if(pData.length >= 4){

                String promoDisplayCode = pData[0];
                String promoDisplayType = pData[1];
                double promoDisplayValue = 0.0;
                String promoDisplayDesc = pData[3];

                try{
                    promoDisplayValue = Double.parseDouble(pData[2]);
                }catch(Exception e){
                    promoDisplayValue = 0.0;
                }
    %>

        <div class="promo-box">
            <b><%= promoDisplayCode %></b><br>
            <%= promoDisplayDesc %><br>
            <small>
                <%= "PERCENT".equalsIgnoreCase(promoDisplayType)
                    ? String.format("%.0f%% OFF", promoDisplayValue)
                    : "RM " + String.format("%.2f", promoDisplayValue) + " OFF" %>
            </small>
        </div>

    <%
            }
        }
    }
    %>

    <form method="post" action="applyPromo.jsp" class="promo-apply-form">
        <input type="text" name="promo" placeholder="Enter promo code here" required>
        <button type="submit" class="btn">Apply Promo</button>
    </form>

    <a href="checkout.jsp" class="back-btn">Back to Checkout</a>

</div>

<%@ include file="footer.jsp" %>

</body>
</html>
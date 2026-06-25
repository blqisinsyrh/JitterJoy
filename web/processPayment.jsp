<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*, java.io.*" %>
<%@ page import="com.connection.DBConnection" %>

<%
/* =======================================================
   1. LOGIN CHECK
   ======================================================= */
if(session.getAttribute("user") == null){
    response.sendRedirect("login.jsp?msg=loginRequired");
    return;
}

/* =======================================================
   2. GET DATA SAFE
   ======================================================= */
String method = request.getParameter("method");
String orderId = (String) session.getAttribute("orderId");
Double total = (Double) session.getAttribute("finalTotal");
List<String> cart = (List<String>) session.getAttribute("cart");

if(method == null || method.trim().isEmpty()){
    out.println("<div style='color:red;text-align:center;'>Invalid payment data: method missing</div>");
    return;
}

/* Only allow Cash and ToyyibPay */
if(!"cash".equals(method) && !"toyyib".equals(method)){
    out.println("<div style='color:red;text-align:center;'>Invalid payment method selected</div>");
    return;
}

if(orderId == null){
    orderId = "OID" + System.currentTimeMillis();
    session.setAttribute("orderId", orderId);
}

if(total == null){
    total = 0.0;
}

/* =======================================================
   3. CONNECT DB & SAVE ORDER + ITEMS + PAYMENT
   ======================================================= */
Connection conn = null;

try {
    conn = DBConnection.getConnection();

    if(conn == null){
        out.println("<pre style='color:red'>DATABASE CONNECTION ERROR: Cannot connect to MySQL. Please check MySQL port 3307, database JJ, username root and empty password.</pre>");
        return;
    }

    conn.setAutoCommit(false);

    if(cart != null && !cart.isEmpty()){

        /* A. Insert order */
        PreparedStatement ps1 = conn.prepareStatement(
            "INSERT INTO orders(order_id, total, status) VALUES (?,?,?)"
        );

        ps1.setString(1, orderId);
        ps1.setDouble(2, total);
        ps1.setString(3, "PENDING");
        ps1.executeUpdate();
        ps1.close();

        /* B. Insert order items */
        for(String item : cart){

            String[] d = item.split(":");

            String name = d.length > 0 ? d[0] : "";
            String size = d.length > 1 ? d[1] : "-";
            String priceStr = d.length > 2 ? d[2] : "0";
            String qtyStr = d.length > 3 ? d[3] : "1";
            String note = d.length > 4 ? d[4] : "";
            String sugar = d.length > 5 ? d[5] : "";

            PreparedStatement ps2 = conn.prepareStatement(
                "INSERT INTO order_items(order_id, item_name, qty, price, size, sugar, note) VALUES (?,?,?,?,?,?,?)"
            );

            ps2.setString(1, orderId);
            ps2.setString(2, name);
            ps2.setInt(3, Integer.parseInt(qtyStr));
            ps2.setDouble(4, Double.parseDouble(priceStr));
            ps2.setString(5, size);
            ps2.setString(6, sugar);
            ps2.setString(7, note);

            ps2.executeUpdate();
            ps2.close();
        }

        /* C. Insert payment */
        String paymentStatus = "cash".equals(method) ? "SUCCESS" : "PENDING";
        String paymentMethod = "cash".equals(method) ? "Cash Payment" : "ToyyibPay FPX";

        PreparedStatement psPay = conn.prepareStatement(
            "INSERT INTO payments(order_id, method, amount, status, paid_at) VALUES (?,?,?,?,NOW())"
        );

        psPay.setString(1, orderId);
        psPay.setString(2, paymentMethod);
        psPay.setDouble(3, total);
        psPay.setString(4, paymentStatus);
        psPay.executeUpdate();
        psPay.close();

        conn.commit();

        session.setAttribute("lastOrderId", orderId);
        session.setAttribute("orderStatus", "PENDING");

        List<String> userOrderIds = (List<String>) session.getAttribute("userOrderIds");

        if(userOrderIds == null){
            userOrderIds = new ArrayList<String>();
        }

        if(!userOrderIds.contains(orderId)){
            userOrderIds.add(orderId);
        }

        session.setAttribute("userOrderIds", userOrderIds);

        session.removeAttribute("cart");
        session.removeAttribute("orderId");

    } else {
        out.println("<div style='color:red;text-align:center;'>Your cart is empty.</div>");
        return;
    }

} catch(Exception e){

    if(conn != null){
        try {
            conn.rollback();
        } catch(SQLException se){}
    }

    out.println("<pre style='color:red'>DATABASE TRANSACT ERROR: " + e.getMessage() + "</pre>");
    return;

} finally {

    if(conn != null){
        try {
            conn.close();
        } catch(SQLException e){}
    }
}

/* =======================================================
   4. CASH PAYMENT REDIRECT
   ======================================================= */
if("cash".equals(method)){

    session.setAttribute("paymentMethod", "Cash Payment");

    response.sendRedirect(
        "paymentSuccess.jsp?orderId=" + URLEncoder.encode(orderId, "UTF-8")
    );

    return;
}

/* =======================================================
   5. TOYYIBPAY INTEGRATION
   ======================================================= */
if("toyyib".equals(method)){

    try {

        String secretKey = "rspyryxb-3fjr-b5j3-js4z-8psynphmhmkx";
        String categoryCode = "m5ghq8we";

        int amountCent = (int)(total * 100);

        String scheme = request.getScheme();
        String serverName = request.getServerName();
        int serverPort = request.getServerPort();
        String contextPath = request.getContextPath();

        String returnUrl =
            scheme + "://" + serverName + ":" + serverPort + contextPath
            + "/paymentSuccess.jsp?orderId="
            + URLEncoder.encode(orderId, "UTF-8");

        String clientName = (String) session.getAttribute("user");

        if(clientName == null || clientName.trim().isEmpty()){
            clientName = "Customer";
        }

        String clientEmail = "customer@email.com";
        String clientPhone = "0123456789";

        String data =
            "userSecretKey=" + URLEncoder.encode(secretKey, "UTF-8")
            + "&categoryCode=" + URLEncoder.encode(categoryCode, "UTF-8")
            + "&billName=" + URLEncoder.encode("FoodOrder", "UTF-8")
            + "&billDescription=" + URLEncoder.encode("PaymentForFood", "UTF-8")
            + "&billPriceSetting=1"
            + "&billPayorInfo=1"
            + "&billAmount=" + amountCent
            + "&billReturnUrl=" + URLEncoder.encode(returnUrl, "UTF-8")
            + "&billTo=" + URLEncoder.encode(clientName, "UTF-8")
            + "&billEmail=" + URLEncoder.encode(clientEmail, "UTF-8")
            + "&billPhone=" + URLEncoder.encode(clientPhone, "UTF-8");

        URL url = new URL("https://toyyibpay.com/index.php/api/createBill");
        HttpURLConnection connHttp = (HttpURLConnection) url.openConnection();

        connHttp.setRequestMethod("POST");
        connHttp.setDoOutput(true);
        connHttp.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

        OutputStream os = connHttp.getOutputStream();
        os.write(data.getBytes("UTF-8"));
        os.flush();
        os.close();

        BufferedReader br = new BufferedReader(
            new InputStreamReader(connHttp.getInputStream())
        );

        String line;
        StringBuilder result = new StringBuilder();

        while((line = br.readLine()) != null){
            result.append(line);
        }

        br.close();

        String jsonResponse = result.toString();

        if(jsonResponse.contains("BillCode")){

            String billCode =
                jsonResponse.replaceAll(".*\"BillCode\":\"(.*?)\".*", "$1");

            session.setAttribute("paymentMethod", "ToyyibPay FPX");

            response.sendRedirect("https://toyyibpay.com/" + billCode);
            return;

        } else {

            out.println("<div style='color:red; text-align:center; margin-top:50px;'>");
            out.println("<h3>ToyyibPay API Error</h3>");
            out.println("<p>Response: " + jsonResponse + "</p>");
            out.println("</div>");
            return;
        }

    } catch(Exception e){

        out.println("<pre style='color:red'>TOYYIBPAY CONNECTION ERROR: " + e.getMessage() + "</pre>");
        return;
    }
}
%>
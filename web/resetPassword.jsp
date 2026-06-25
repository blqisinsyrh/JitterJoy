<%-- 
    Document   : resetPassword
    Created on : 22 Apr 2026, 4:08:48?pm
    Author     : ADMIN
--%>

<%@page import="java.util.Map"%>
<%@ include file="header.jsp" %>
<link rel="stylesheet" href="style.css">

<div class="content">

<div class="card login-card">

<%
String user = (String) session.getAttribute("resetUser");

if(user == null){
    out.println("No reset request");
    return;
}

Map<String, String> users = (Map<String, String>) session.getAttribute("users");
String newPass = request.getParameter("newpass");

if(newPass != null){

    users.put(user, newPass);
    session.setAttribute("users", users);

    out.println("<p style='color:green;'>Password updated ?</p>");
}
%>

    <h2>Reset Password</h2>

    <form method="post">

        <input type="password" name="newpass" placeholder="New Password" required>
        <button class="btn">Update</button>

    </form>

</div>

</div>

<%@ include file="footer.jsp" %>

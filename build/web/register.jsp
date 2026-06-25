<%-- 
    Document   : register
    Created on : 22 Apr 2026, 12:24:58?pm
    Author     : Acer
--%>

<%@ page import="java.util.*" %>
<%@ page import="com.model.User" %>
<%@ page import="com.dao.UserDAO" %>
<link rel="stylesheet" href="style.css">
<%@ include file="header.jsp" %>

<div class="content">
<div class="card login-card">

<h2>Create Account</h2>

<%
String u = request.getParameter("username");
String e = request.getParameter("email"); // 1. Ambil input email
String p = request.getParameter("password");

if(u != null && p != null && e != null){

    u = u.trim();
    e = e.trim();
    
    // 2. Cipta objek User baru dan set nilainya
    User newUser = new User();
    newUser.setUsername(u);
    newUser.setEmail(e);
    newUser.setPassword(p);
    
    // 3. Panggil UserDAO untuk simpan ke database
    UserDAO dao = new UserDAO();
    boolean isSaved = dao.register(newUser);

    if(isSaved){
%>
        <p style="color:green;">Register successful into Database!</p>
        <a href="login.jsp">Go to Login</a>
<%
    } else {
%>
        <p style="color:red;">Register failed! Username might already exist or DB error.</p>
<%
    }
}
%>

<form method="post">

    <input name="username" placeholder="Username" required>
    <input name="email" type="email" placeholder="Email" required> 
    <input name="password" type="password" placeholder="Password" required>

    <button class="btn" type="submit">Register</button>

</form>

</div>
</div>

<%@ include file="footer.jsp" %>
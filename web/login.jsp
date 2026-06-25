<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%@ page import="com.model.User" %>
<%@ page import="com.dao.UserDAO" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Jitter & Joy | Login</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>

<%
// Ambil data input daripada borang (form)
String input = request.getParameter("username");
String p = request.getParameter("password");

// Proses data hanya jika pengguna menekan butang Login (input tidak kosong)
if(input != null && p != null){

    input = input.trim();

    /* =======================================================
       1. SEMAK LOG IN UNTUK ADMIN (HARDCODE)
    ======================================================= */
    if(input.equalsIgnoreCase("admin@gmail.com") && "1234".equals(p)){
        session.setAttribute("role", "admin");
        session.setAttribute("user", "Admin");
        response.sendRedirect("admin.jsp");
        return; // Hentikan proses seterusnya jika pautan berjaya
    }

    /* =======================================================
       2. SEMAK LOG IN UNTUK CUSTOMER (DATABASE GUNA DAO)
    ======================================================= */
    UserDAO dao = new UserDAO();
    User loggedInUser = dao.login(input, p); 

    if(loggedInUser != null) {
        // Jika data pengguna dijumpai dalam pangkalan data
        session.setAttribute("role", "user");
        session.setAttribute("user", loggedInUser.getUsername());
        session.setAttribute("userId", loggedInUser.getId()); 
        
        response.sendRedirect("index.jsp");
        return; // Hentikan proses seterusnya
    }

    /* =======================================================
       3. PAPAR RALAT JIKA KEDUA-DUA DI ATAS GAGAL
    ======================================================= */
    out.println("<p style='color:red; text-align:center; margin-top:20px; font-weight:bold;'>Invalid login</p>");
}
%>

<div class="card login-card">

    <h2>Welcome Back</h2>

    <form method="post" action="login.jsp">

        <input name="username" placeholder="Username or Email" required>
        <input type="password" name="password" placeholder="Password" required>

        <button class="btn" type="submit">Login</button>

    </form>

    <p>
        <a href="register.jsp">Create Account</a> |
        <a href="forgotPassword.jsp">Forgot Password</a>
    </p>

</div>

</body>
</html>
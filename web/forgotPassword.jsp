
<%@page import="java.util.Map"%>
<link rel="stylesheet" href="style.css">

<div class="content">

<div class="card login-card">

    <h2>Forgot Password</h2>

    <form method="post">

        <input name="input" placeholder="Username or Email" required>
        <button class="btn">Check</button>

    </form>

<%
String input = request.getParameter("input");

if(input != null){

    Map<String, String> users = (Map<String, String>) session.getAttribute("users");

    if(users != null && users.containsKey(input)){

        session.setAttribute("resetUser", input);
%>

        <p style="color:green;">Account found ?</p>
        <a href="resetPassword.jsp">Reset Password</a>

<%
    } else {
%>

        <p style="color:red;">User not found</p>

<%
    }
}
%>

</div>

</div>

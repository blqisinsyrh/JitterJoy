
    Document   : logout
    Created on : 22 Apr 2026, 2:49:54?pm
    Author     : alessa
--%>

<%
session.invalidate();
response.sendRedirect("login.jsp");
%>





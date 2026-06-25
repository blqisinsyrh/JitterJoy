<%@ page import="java.sql.*" %>
<%@ page import="com.connection.DBConnection" %>
<%
Connection conn = DBConnection.getConnection();
if(conn == null){
    throw new ServletException("Database connection failed. Please make sure MySQL is running on port 3307 and database JJ exists.");
}
%>

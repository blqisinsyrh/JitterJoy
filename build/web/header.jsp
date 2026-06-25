<link rel="stylesheet" href="<%= request.getContextPath() %>/style.css">

<div class="page-wrapper">

<div class="navbar">

    <div class="logo">Jitter & Joy</div>

    <div class="nav-center">
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/menu.jsp">Menu</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
        <a href="<%= request.getContextPath() %>/orderHistory.jsp">Order</a>
        <a href="<%= request.getContextPath() %>/applyPromo.jsp">Promo</a>
    </div>

    <div class="nav-right">

        <%-- LOGIN / LOGOUT --%>
        <% if(session.getAttribute("role") == null){ %>
            <a href="<%= request.getContextPath() %>/login.jsp">Login</a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/logout.jsp">Logout</a>
        <% } %>

        <%-- ADMIN ONLY --%>
        <% if("admin".equals(session.getAttribute("role"))){ %>
            <a href="<%= request.getContextPath() %>/admin.jsp">Admin</a>
        <% } %>

    </div>

</div>

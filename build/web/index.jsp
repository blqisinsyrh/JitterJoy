<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ include file="header.jsp" %>

<!-- HERO -->
<section class="home-hero">

    <div class="top-actions">
        <div class="branch-select">
            <select>
                <option>Select Branch</option>
                <option>Kuala Terengganu</option>
                <option>Gong Badak</option>
                <option>Batu Buruk</option>
            </select>
        </div>

        <a href="<%= request.getContextPath() %>/orderHistory.jsp" class="last-order-btn">Last Order</a>
    </div>

    <div class="carousel">
        <div class="slides">
            <div class="slide"><img src="<%= request.getContextPath() %>/images/banner1.png" alt="Jitter & Joy Banner 1"></div>
            <div class="slide"><img src="<%= request.getContextPath() %>/images/banner2.png" alt="Jitter & Joy Banner 2"></div>
            <div class="slide"><img src="<%= request.getContextPath() %>/images/banner3.png" alt="Jitter & Joy Banner 3"></div>
        </div>
    </div>

</section>

<!-- OPERATIONAL HOURS -->
<section class="section">
    <div class="info-card">
        <h2 class="section-title">Operational Hours</h2>
        <p>8:00 AM - 10:00 PM</p>

        <%
        int hour = java.time.LocalTime.now().getHour();
        boolean open = hour >= 8 && hour <= 22;
        %>

        <% if(open){ %>
            <p class="open-status">We are OPEN now</p>
        <% } else { %>
            <p class="closed-status">Sorry, we are CLOSED</p>
        <% } %>
    </div>
</section>

<!-- ORDER BY CATEGORIES -->
<section class="section order-category-section">
    <div class="category-heading">
        <h2 class="section-title">Order by Categories</h2>
        <p>Choose your favourite category and continue ordering from the menu page.</p>
    </div>

    <div class="category-buttons">
        <a href="<%= request.getContextPath() %>/menu.jsp?category=hot" class="category-btn">Hot Drinks</a>
        <a href="<%= request.getContextPath() %>/menu.jsp?category=cold" class="category-btn">Cold Drinks</a>
        <a href="<%= request.getContextPath() %>/menu.jsp?category=frappe" class="category-btn">Frappe</a>
        <a href="<%= request.getContextPath() %>/menu.jsp?category=pastry" class="category-btn">Pastry</a>
        <a href="<%= request.getContextPath() %>/menu.jsp?category=cake" class="category-btn">Cake</a>
        <a href="<%= request.getContextPath() %>/menu.jsp" class="category-btn all-menu">All Menu</a>
    </div>
</section>

<%@ include file="footer.jsp" %>

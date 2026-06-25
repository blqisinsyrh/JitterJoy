<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.connection.DBConnection" %>
<%@ include file="header.jsp" %>

<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public boolean matchCategory(String dbCategory, String targetCategory) {
        if (dbCategory == null || targetCategory == null) return false;
        dbCategory = dbCategory.toLowerCase().trim();
        targetCategory = targetCategory.toLowerCase().trim();
        if (dbCategory.equals(targetCategory)) return true;

        // allow old database category name to still show under Cold Drinks
        if (targetCategory.equals("cold") && dbCategory.equals("iced")) return true;

        return false;
    }

    public boolean hasCategory(List<Map<String, String>> items, String category) {
        for (Map<String, String> item : items) {
            if (matchCategory(item.get("category"), category)) return true;
        }
        return false;
    }
%>

<div class="card" style="text-align:center; padding:10px 0;">
    <h2>Our Menu</h2>
</div>

<div class="menu-controls">
    <div class="menu-control-title">
        <span>Browse Menu</span>
        <small>Choose Dishes or Beverages from the sidebar and search your favourite item.</small>
    </div>

    <div class="menu-search">
        <input type="text" id="menuSearch" class="search-box" placeholder="Search menu item..." onkeydown="handleSearchKey(event)">
        <button type="button" class="search-btn" onclick="searchMenu()">Search</button>
    </div>
</div>

<div class="menu-page-layout">
    <aside class="menu-sidebar">
        <div class="sidebar-title">Categories</div>
        <button id="btn-dishes" class="sidebar-link active" onclick="showTab('dishes')">Dishes</button>
        <button id="btn-beverages" class="sidebar-link" onclick="showTab('beverages')">Beverages</button>
    </aside>

    <main class="menu-main">
        <p id="noResults" class="no-results" style="display:none;">No menu item found. Try another keyword.</p>

<%
List<Map<String, String>> items = new ArrayList<Map<String, String>>();
Connection conn = null;
PreparedStatement ps = null;
ResultSet rs = null;

try {
    conn = DBConnection.getConnection();

    if (conn == null) {
        out.println("<p style='color:red; text-align:center; font-weight:bold;'>Ralat Database: Connection failed. Check database name, MySQL service, username/password and JDBC driver.</p>");
    } else {
        String sql = "SELECT id, item_name, price, image, category, description, status "
                   + "FROM menu "
                   + "WHERE status = 'Available' "
                   + "ORDER BY FIELD(category,'hot','cold','iced','frappe','pastry','cake'), item_name";

        ps = conn.prepareStatement(sql);
        rs = ps.executeQuery();

        while (rs.next()) {
            Map<String, String> item = new HashMap<String, String>();
            item.put("id", String.valueOf(rs.getInt("id")));
            item.put("name", rs.getString("item_name"));
            item.put("price", String.format("%.2f", rs.getDouble("price")));
            item.put("image", rs.getString("image"));
            item.put("category", rs.getString("category") == null ? "" : rs.getString("category").toLowerCase().trim());
            item.put("description", rs.getString("description"));
            item.put("status", rs.getString("status"));
            items.add(item);
        }
    }
} catch (Exception e) {
    out.println("<p style='color:red; text-align:center; font-weight:bold;'>Ralat Database: " + h(e.getMessage()) + "</p>");
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (ps != null) try { ps.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}

String[][] dishSections = {
    {"pastry", "Pastry"},
    {"cake", "Cake"}
};

String[][] beverageSections = {
    {"hot", "Hot Drinks"},
    {"cold", "Cold Drinks"},
    {"frappe", "Frappe"}
};
%>

        <div id="dishes" class="menu-section">
            <%
            for (int i = 0; i < dishSections.length; i++) {
                String categoryKey = dishSections[i][0];
                String categoryTitle = dishSections[i][1];
                if (hasCategory(items, categoryKey)) {
            %>
                    <h3 class="category-title"><%= categoryTitle %></h3>
                    <div class="menu-container">
                        <%
                        for (Map<String, String> item : items) {
                            if (matchCategory(item.get("category"), categoryKey)) {
                        %>
                            <div class="menu-card menu-item"
                                 data-name="<%= h(item.get("name")) %>"
                                 data-price="<%= h(item.get("price")) %>"
                                 data-category="<%= h(item.get("category")) %>"
                                 data-search="<%= h((item.get("name") + " " + item.get("description") + " " + item.get("category")).toLowerCase()) %>">
                                <img src="images/<%= h(item.get("image")) %>" onerror="this.src='images/default.jpeg'">
                                <h3><%= h(item.get("name")) %></h3>
                                <p><b>RM <%= h(item.get("price")) %></b></p>
                                <p style="font-size:12px;color:gray;"><%= h(item.get("description")) %></p>
                                <button class="btn" onclick="openModalFromButton(this)">Add to Cart</button>
                            </div>
                        <%
                            }
                        }
                        %>
                    </div>
            <%
                }
            }
            %>
        </div>

        <div id="beverages" class="menu-section" style="display:none;">
            <%
            for (int i = 0; i < beverageSections.length; i++) {
                String categoryKey = beverageSections[i][0];
                String categoryTitle = beverageSections[i][1];
                if (hasCategory(items, categoryKey)) {
            %>
                    <h3 class="category-title"><%= categoryTitle %></h3>
                    <div class="menu-container">
                        <%
                        for (Map<String, String> item : items) {
                            if (matchCategory(item.get("category"), categoryKey)) {
                        %>
                            <div class="menu-card menu-item"
                                 data-name="<%= h(item.get("name")) %>"
                                 data-price="<%= h(item.get("price")) %>"
                                 data-category="<%= h(item.get("category")) %>"
                                 data-search="<%= h((item.get("name") + " " + item.get("description") + " " + item.get("category")).toLowerCase()) %>">
                                <img src="images/<%= h(item.get("image")) %>" onerror="this.src='images/default.jpeg'">
                                <h3><%= h(item.get("name")) %></h3>
                                <p><b>RM <%= h(item.get("price")) %></b></p>
                                <p style="font-size:12px;color:gray;"><%= h(item.get("description")) %></p>
                                <button class="btn" onclick="openModalFromButton(this)">Add to Cart</button>
                            </div>
                        <%
                            }
                        }
                        %>
                    </div>
            <%
                }
            }
            %>
        </div>
    </main>
</div>

<div id="cartModal" class="modal-bg">
    <div class="modal-box">
        <h2 id="itemName"></h2>
        <p id="itemPrice"></p>

        <div id="drinkOption" style="display:none;">
            <p>Sugar Level</p>
            <select id="sugar">
                <option value="Normal Sugar">Normal Sugar</option>
                <option value="Less Sugar">Less Sugar</option>
                <option value="Extra Sugar">Extra Sugar</option>
                <option value="No Sugar">No Sugar</option>
            </select>
        </div>

        <p>Special Note:</p>
        <textarea id="note" rows="3" placeholder="E.g., less ice, extra hot, no cream..."></textarea>
        <br><br>
        <button class="btn" onclick="confirmAdd()">Confirm</button>
        <button class="btn" style="background:#888;" onclick="closeModal()">Close</button>
    </div>
</div>

<script>
let currentItem = "";
let currentPrice = 0;
let currentCategory = "";
let activeCategoryFilter = "";

function resetModal(){
    document.getElementById("drinkOption").style.display = "none";
    document.getElementById("note").value = "";
    document.getElementById("sugar").value = "Normal Sugar";
}

function openModalFromButton(button){
    let card = button.closest(".menu-card");
    openModal(card.dataset.name, card.dataset.price, card.dataset.category);
}

function openModal(name, price, category){
    resetModal();
    currentItem = name;
    currentPrice = parseFloat(price);
    currentCategory = (category || "").toLowerCase().trim();

    document.getElementById("itemName").innerText = name;
    document.getElementById("itemPrice").innerText = "RM " + currentPrice.toFixed(2);
    document.getElementById("cartModal").style.display = "block";

    if(currentCategory === "hot" || currentCategory === "cold" || currentCategory === "iced" || currentCategory === "frappe"){
        document.getElementById("drinkOption").style.display = "block";
    }
}

function closeModal(){
    document.getElementById("cartModal").style.display = "none";
}

function showTab(tab, keepCategoryFilter){
    if(!keepCategoryFilter){
        activeCategoryFilter = "";
    }
    document.getElementById("dishes").style.display = "none";
    document.getElementById("beverages").style.display = "none";
    document.getElementById("btn-dishes").classList.remove("active");
    document.getElementById("btn-beverages").classList.remove("active");

    document.getElementById(tab).style.display = "block";
    document.getElementById("btn-" + tab).classList.add("active");
    searchMenu();
}

function handleSearchKey(event){
    if(event.key === "Enter"){
        event.preventDefault();
        searchMenu();
    }
}

function searchMenu(){
    let input = document.getElementById("menuSearch").value.toLowerCase().trim();
    let activeTab = document.getElementById("dishes").style.display !== "none" ? "dishes" : "beverages";
    let items = document.querySelectorAll("#" + activeTab + " .menu-item");
    let totalVisible = 0;

    items.forEach(item => {
        let text = (item.dataset.search || item.innerText).toLowerCase();
        let itemCategory = (item.dataset.category || "").toLowerCase().trim();
        let matchText = input === "" || text.includes(input);
        let matchCategory = activeCategoryFilter === "" || itemCategory === activeCategoryFilter || (activeCategoryFilter === "cold" && itemCategory === "iced");

        if(matchText && matchCategory){
            item.style.display = "block";
            totalVisible++;
        } else {
            item.style.display = "none";
        }
    });

    let sections = document.querySelectorAll("#" + activeTab + " .menu-container");
    sections.forEach(section => {
        let title = section.previousElementSibling;
        let visibleItems = Array.from(section.querySelectorAll(".menu-item")).filter(item => item.style.display !== "none");
        title.style.display = visibleItems.length === 0 ? "none" : "block";
    });

    document.getElementById("noResults").style.display = totalVisible === 0 ? "block" : "none";
}

function applyCategoryFromURL(){
    let params = new URLSearchParams(window.location.search);
    let category = (params.get("category") || "").toLowerCase().trim();

    if(category === ""){
        return;
    }

    activeCategoryFilter = category;

    if(category === "hot" || category === "cold" || category === "iced" || category === "frappe"){
        showTab("beverages", true);
    } else {
        showTab("dishes", true);
    }

    searchMenu();
}

window.addEventListener("DOMContentLoaded", applyCategoryFromURL);

function confirmAdd(){
    let sugar = document.getElementById("sugar").value;
    let note = document.getElementById("note").value;

    let url = "cart.jsp?item=" + encodeURIComponent(currentItem)
            + "&price=" + currentPrice.toFixed(2)
            + "&category=" + encodeURIComponent(currentCategory)
            + "&note=" + encodeURIComponent(note);

    if(currentCategory === "hot" || currentCategory === "cold" || currentCategory === "iced" || currentCategory === "frappe"){
        url += "&sugar=" + encodeURIComponent(sugar);
    }

    window.location.href = url;
}
</script>

<%@ include file="footer.jsp" %>

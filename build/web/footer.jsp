<footer class="footer">

<div class="footer-container">

<div class="footer-section">

<h3>Jitter & Joy</h3>

<p>
Premium coffee experience with
minimalist aesthetics and handcrafted
drinks.
</p>

</div>

<div class="footer-section">

<h3>Quick Links</h3>

<ul>

<li>
<a href="<%= request.getContextPath() %>/index.jsp">Home</a>
</li>

<li>
<a href="<%= request.getContextPath() %>/menu.jsp">Menu</a>
</li>

<li>
<a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
</li>

<li>
<a href="<%= request.getContextPath() %>/orderHistory.jsp">Order</a>
</li>

<li>
<a href="<%= request.getContextPath() %>/applyPromo.jsp">Promo</a>
</li>

</ul>

</div>

<div class="footer-section">

<h3>Contact Us</h3>

<p>Kuala Terengganu</p>

<p>+60 11-1234 5678</p>

<p>support@jitterjoy.com</p>

</div>

<div class="footer-section">

<h3>Follow Us</h3>

<div class="social-links">

<a href="#">f</a>

<a href="#">ig</a>

<a href="#">x</a>

<a href="#">tt</a>

</div>

</div>

</div>

<div class="footer-bottom">

<p>© 2026 Jitter & Joy. All Rights Reserved.</p>

</div>

</footer>

<style>
.footer{
    background:#111111;
    color:#ffffff;
    margin-top:60px;
}

.footer-container{
    width:90%;
    margin:auto;
    display:grid;
    grid-template-columns:repeat(auto-fit,minmax(220px,1fr));
    gap:30px;
    padding:50px 0;
}

.footer-section h3{
    margin-bottom:15px;
    color:#ffffff;
}

.footer-section p{
    margin-bottom:10px;
    color:#d6d6d6;
}

.footer-section ul{
    list-style:none;
    padding-left:0;
}

.footer-section ul li{
    margin-bottom:10px;
}

.footer-section ul li a{
    color:#ffffff;
    text-decoration:none;
}

.footer-section ul li a:hover{
    color:#bbbbbb;
}

.social-links{
    display:flex;
    gap:15px;
    margin-top:15px;
}

.social-links a{
    width:40px;
    height:40px;
    border-radius:50%;
    background:#ffffff;
    color:#111111;
    display:flex;
    justify-content:center;
    align-items:center;
    text-decoration:none;
    transition:0.3s;
    font-weight:800;
    text-transform:uppercase;
    font-size:12px;
}

.social-links a:hover{
    transform:translateY(-5px);
    background:#eeeeee;
}

.footer-bottom{
    text-align:center;
    border-top:1px solid rgba(255,255,255,0.18);
    padding:15px;
    font-size:14px;
    color:#d6d6d6;
}
</style>

</div> <!-- close page-wrapper -->

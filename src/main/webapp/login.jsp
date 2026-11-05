<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Login - WildFire Tracker</title></head>
<body>
    <h2>Login</h2>
    <form action="login" method="post">
        <label>Username or Email:</label><input type="text" name="usernameOrEmail" required><br>
        <label>Password:</label><input type="password" name="password" required><br>
        <button type="submit">Login</button>
    </form>
    <a href="signup.jsp">Don't have an account? Sign Up</a>
</body>
</html>
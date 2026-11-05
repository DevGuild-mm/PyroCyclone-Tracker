<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head><title>Sign Up - WildFire Tracker</title></head>
<body>
    <h2>Create Account</h2>
    <form action="signup" method="post">
        <label>Username:</label><input type="text" name="username" required><br>
        <label>Email:</label><input type="email" name="email" required><br>
        <label>Password:</label><input type="password" name="password" required><br>
        <button type="submit">Sign Up</button>
    </form>
    <a href="login.jsp">Already have an account? Login</a>
</body>
</html>
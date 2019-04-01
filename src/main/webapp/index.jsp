<%@page import="org.semanticwb.datamanager.*"%><%        
    SWBScriptEngine eng=DataMgr.initPlatform(session);
    response.sendRedirect("/admin");
    if(true)return;
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Start Page</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    </head>
    <body>
        <h1><%=eng.getAppName()%></h1>
<%        
    DataObject user=eng.getUser(); 
    if(user!=null)
    {
%>
        <h2>User</h2>
        <div>User: <%=user.getString("fullname")%></div>
        <div>Email: <%=user.getString("email")%> </div>
<%
    }
%>        
        <h2>Paths</h2>
        <div><a href="/admin">/admin</a></div>
        <div><a href="/login">/login</a></div>
        <div><a href="/register">/register</a></div>
    </body>
</html>

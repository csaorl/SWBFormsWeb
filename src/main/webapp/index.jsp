<%@page import="org.semanticwb.datamanager.*"%><%        
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/WEB-INF/global.js",session);
    response.sendRedirect(contextPath+"/admin");
    //System.out.println("servletPath:"+request.getAttribute("servletPath"));
    //System.out.println("contextPath:"+request.getAttribute("contextPath"));
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
        <div><a href="<%=contextPath%>/admin">/admin</a></div>
        <div><a href="<%=contextPath%>/login">/login</a></div>
        <div><a href="<%=contextPath%>/register">/register</a></div>
    </body>
</html>

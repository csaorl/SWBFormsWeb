<%-- 
    Document   : users.jsp
    Created on : 22-jul-2018, 23:15:13
    Author     : javiersolis
--%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/datasources.js", session);
    DataObject user = eng.getUser();
    user.addSubList("roles").add("prog");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Hello World!</h1>
    </body>
</html>

<%-- 
    Document   : datasources.js
    Created on : 17-feb-2018, 21:28:26
    Author     : javiersolis
--%><%@page import="org.semanticwb.swbforms.admin.AdminUtils"%><%@page import="java.util.Iterator"%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/javascript" pageEncoding="UTF-8"%><%!

%><%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin_base.js", session);  
/*    
    if(eng.isNeedsReloadScriptEngine())
    {
        eng.reloadAllScriptEngines();
    }
*/
    out.print(AdminUtils.getDataSourceScriptFromDB(eng.getUser(),request.getParameter("backend")==null));
%>
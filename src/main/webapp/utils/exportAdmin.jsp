<%-- 
    Document   : exportAdmin
    Created on : 23-jul-2018, 12:43:29
    Author     : javiersolis
--%><%@page import="java.nio.charset.Charset"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Export Admin</h1>
<%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
    DataObject data=new DataObject();
    data.addParam("DataSource",eng.getDataSource("DataSource").fetch().getDataObject("response").getDataList("data"));
    data.addParam("DataSourceFields",eng.getDataSource("DataSourceFields").fetch().getDataObject("response").getDataList("data"));
    data.addParam("DataSourceFieldsExt",eng.getDataSource("DataSourceFieldsExt").fetch().getDataObject("response").getDataList("data"));
    data.addParam("ValueMapValues",eng.getDataSource("ValueMapValues").fetch().getDataObject("response").getDataList("data"));
    data.addParam("ValueMap",eng.getDataSource("ValueMap").fetch().getDataObject("response").getDataList("data"));
    data.addParam("ValidatorExt",eng.getDataSource("ValidatorExt").fetch().getDataObject("response").getDataList("data"));
    data.addParam("Validator",eng.getDataSource("Validator").fetch().getDataObject("response").getDataList("data"));
    data.addParam("DataService",eng.getDataSource("DataService").fetch().getDataObject("response").getDataList("data"));
    data.addParam("DataProcessor",eng.getDataSource("DataProcessor").fetch().getDataObject("response").getDataList("data"));
    data.addParam("PageProps",eng.getDataSource("PageProps").fetch().getDataObject("response").getDataList("data"));
    data.addParam("Page",eng.getDataSource("Page").fetch().getDataObject("response").getDataList("data"));
    data.addParam("User",eng.getDataSource("User").fetch().getDataObject("response").getDataList("data"));
    out.println(data);
    FileOutputStream fout=new FileOutputStream(DataMgr.getApplicationPath()+"/WEB-INF/admindb.json");
    fout.write(data.toString().getBytes(Charset.forName("utf8")));
    fout.close();
%>            
    </body>
</html>

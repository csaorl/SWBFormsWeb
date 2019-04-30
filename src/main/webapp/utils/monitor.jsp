<%-- 
    Document   : monitor
    Created on : 23-abr-2019, 15:45:32
    Author     : javiersolis
--%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.datamanager.monitor.SWBMonitorRecord"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="org.semanticwb.datamanager.monitor.SWBMonitorMgr"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Monitor Page</title>
    </head>
    <body>
        <h1>Monitor</h1>        
        <table>
            <tr><th>Path</th><th>Times</th><th>First</th><th>Min</th><th>Average</th><th>Max</th><th>Last</th></tr>
<%
    Iterator<String> it=SWBMonitorMgr.getStats().keySet().stream().sorted().iterator();    
    //Iterator<Entry<String,SWBMonitorRecord>> it=SWBMonitorMgr.getStats().entrySet().iterator();
    while (it.hasNext()) {
        //Entry<String,SWBMonitorRecord> entry = it.next();        
        String path=it.next();            
        SWBMonitorRecord record=SWBMonitorMgr.getStats().get(path);
%>
            <tr><td><%=path%></td><td><%=record.getTimes()%></td><td><%=record.getFirstTime()%></td><td><%=record.getMinTime()%></td><td><%=record.getAverageTime()%></td><td><%=record.getMaxTime()%></td><td><%=record.getLastTime()%></tr>
<%
    }
%>
        </table>
    </body>
</html>

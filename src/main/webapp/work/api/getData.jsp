<%-- 
    Document   : post
    Created on : 15-jun-2017, 22:08:23
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataObject"%><%@page import="java.util.*"%><%
    String contextPath = request.getContextPath();
    String uri=request.getRequestURI();
    StringTokenizer st=new StringTokenizer(uri,"/");
    String api=st.nextToken();
    String serv=st.nextToken();
    String authtoken=null;
    String topic=null;    
    String contentType=null;    
    if(st.hasMoreTokens())authtoken=st.nextToken();
    if(st.hasMoreTokens())topic=st.nextToken();
    if(st.hasMoreTokens())contentType=st.nextToken();
    if(authtoken==null)
    {
        out.println("Forms HTTP API:");
        out.println("GET "+contextPath+"/api/getData/[Authentication Token]/[Topic]/[Content_Type]");
    }
    out.println("authtoken:"+authtoken);
    out.println("topic:"+topic);    
    out.println("contentType:"+contentType);
%>
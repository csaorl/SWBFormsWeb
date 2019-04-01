<%-- 
    Document   : post
    Created on : 15-jun-2017, 22:08:23
    Author     : javiersolis
--%><%@page import="java.io.IOException"%><%@page import="java.util.StringTokenizer"%><%
    String uri=request.getRequestURI();
    StringTokenizer st=new StringTokenizer(uri,"/");
    String api=st.nextToken();
    String serv=null;
    if(st.hasMoreTokens())serv=st.nextToken();
    
    if(serv==null)
    {
        request.getRequestDispatcher("/work/apiDesc.jsp").include(request, response);
    }else
    {      
        request.getRequestDispatcher("/work/api/"+serv+".jsp").include(request, response);
    }
%>
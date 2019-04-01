<%-- 
    Document   : index
    Created on : 15-abr-2017, 12:26:32
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.*"%><%
    System.out.println("Validator");
    SWBScriptEngine engine = DataMgr.initPlatform("/admin/ds/base.js",session);

    String cmd = (String)request.getAttribute("servletPath");
    cmd = cmd.substring(cmd.lastIndexOf("/") + 1);
    
    System.out.println("Validator:"+cmd);    
    System.out.println(request.getServletContext());    
    System.out.println(request.getRequestURI());    
    System.out.println(request.getRequestURL());    
    System.out.println(request.getPathInfo());    
    System.out.println(request.getPathTranslated());    
    
    switch (cmd) {
        case "email": {
            String email = request.getParameter("email");
            if (email != null) {
                DataObject data = new DataObject();
                data.put("email", email);
                DataObject query = new DataObject();
                query.put("data", data);
                query = engine.getDataSource("User").fetch(query);
                DataList lista = query.getDataObject("response").getDataList("data");
                if (lista.size() == 0) {
                    response.getWriter().println("ok");
                } else {
                    response.sendError(409, "email already in use");
                }
            }
            break;
        }
        case "existEmail": {
            String email = request.getParameter("email");
            if (email != null) {
                DataObject data = new DataObject();
                data.put("email", email);
                DataObject query = new DataObject();
                query.put("data", data);
                query = engine.getDataSource("User").fetch(query);
                DataList lista = query.getDataObject("response").getDataList("data");
                if (lista.size() == 0) {
                    response.sendError(409, "email not exist");                        
                } else {
                    response.getWriter().println("ok");
                }
            }
            break;
        }
        default: {
            response.sendError(405, "No Validator available for that message");
        }
    }    
%>
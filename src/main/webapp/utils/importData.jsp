<%-- 
    Document   : importAdmin
    Created on : 23-jul-2018, 12:43:37
    Author     : javiersolis
--%><%@page import="java.util.Map"%>
<%@page import="java.util.Map.Entry"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Arrays"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.nio.charset.Charset"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!

    public boolean importDatasource(String key, DataObject data, SWBScriptEngine eng)
    {
        int x=0;
        try
        {
            SWBDataSource ds=eng.getDataSource(key);
            Object obj=data.get(key);
            DataList<DataObject> list=data.getDataList(key);
            //System.out.println(obj+" "+list);
            if(ds!=null)
            {
                if(list!=null)
                {
                    for(DataObject ele:list)
                    {
                        ds.addObj(ele);
                        x++;
                    }
                }else System.out.println("No se encontratron datos de "+key);
                return true;
            }else System.out.println("No se encontro datasource "+key);
        }catch(Exception e)
        {
            System.out.println("ds:"+key+" x:"+x);
            e.printStackTrace();
        }
        return false;
    }

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <h1>Import Admin</h1>
        <pre>
<%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
    FileInputStream fin = new FileInputStream(DataMgr.getApplicationPath() + "/WEB-INF/admindb.json");
    DataObject data = (DataObject) DataObject.parseJSON(DataUtils.readInputStream(fin, "utf8"));
    
    String dss[]={"DataSource","DataSourceFields","DataSourceFieldsExt","ValueMapValues","ValueMap","ValidatorExt","Validator","DataService","DataProcessor","PageProps","Page","User"};
    
    for(String key:dss)
    {
        out.println(key+" ");
        //out.println(importDatasource(key,data,eng));
    }
    eng.reloadAllScriptEngines();
    
    List lst=Arrays.asList(dss);
        
    Iterator<Map.Entry<String,Object>> it = data.entrySet().iterator();
    while (it.hasNext()) 
    {
        Map.Entry<String,Object> entry=it.next();
        String key = entry.getKey();
        out.println(key+" "+entry.getValue());
        if(!lst.contains(key))
        {
            out.println("["+key+"]"+" "+(data.get(key)!=null)+" ");
            //out.println(importDatasource(key,data,eng));
        }
    }    
%>            
        </pre>        
    </body>
</html>

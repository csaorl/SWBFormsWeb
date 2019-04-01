<%-- 
    Document   : importAdmin
    Created on : 23-jul-2018, 12:43:37
    Author     : javiersolis
--%><%@page import="java.util.Iterator"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="java.nio.charset.Charset"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.File"%>
<%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    public String parseId(String id, SWBScriptEngine eng)
    {
        if(id.startsWith("_suri:"))
        {
            String modelid=null;
            String clsname=null;
            String nid=null;

            int i1 = id.indexOf(":");
            if (i1 > -1) {
                int i2 = id.indexOf(":", i1 + 1);
                if (i2 > -1) {
                    modelid=id.substring(i1 + 1, i2);
                    int i3 = id.indexOf(":", i2 + 1);
                    if (i3 > -1) 
                    {
                        clsname=id.substring(i2 + 1, i3);
                        nid=id.substring(i3 + 1);

                        id=eng.getDataSource(clsname).getBaseUri()+nid;
                    }
                }
            }                              
        }   
        return id;
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
    
    eng.setDisabledDataTransforms(true);
    try
    {
        Iterator<String> keys = data.keySet().iterator();
        while (keys.hasNext()) {
            String key = keys.next();
            out.println(key);
            DataList<DataObject> list=data.getDataList(key);
            for(DataObject ele:list)
            {
                //out.println("  "+ele);
                SWBDataSource ds=eng.getDataSource(key);

                //convertir Model_Ids
                Iterator<String> keys2=ele.keySet().iterator();
                while (keys2.hasNext()) {
                    String key2 = keys2.next();
                    if(key2.equals("_id"))continue;
                    Object obj=ele.get(key2);
                    if(obj instanceof String)
                    {
                        String id=(String)obj;
                        String id2=parseId(id,eng);
                        if(!id.equals(id2))ele.put(key2,id2);
                    }else if(obj instanceof DataList)
                    {
                        //out.println(key2+"->"+obj);
                        
                        DataList dl=(DataList)obj;
                        for(int x=0;x<dl.size();x++)
                        {
                            Object obj2=dl.get(x);
                            if(obj2 instanceof String)
                            {
                                String id=(String)obj2;
                                String id2=parseId(id,eng);
                                //out.println("    "+id+"->"+id2);
                                if(!id.equals(id2))dl.set(x,id2);
                            }
                        }
                        
                    }else
                    {
                        //out.println(obj);
                    }
                }

                String _id=ds.getBaseUri()+ele.getNumId();
                ele.addParam("_id", _id);

                out.println("  "+ele);

                if(ds.fetchObjById(_id)!=null)
                {
                    ds.updateObj(ele);
                }else
                {
                    ds.addObj(ele);
                }
            }
        }    
    }catch(Exception e)
    {
        e.printStackTrace();
    }finally
    {
        eng.setDisabledDataTransforms(false);
    }
%>            
        </pre>        
    </body>
</html>

<%-- 
    Document   : exportAdmin
    Created on : 23-jul-2018, 12:43:29
    Author     : javiersolis
--%><%@page import="java.util.zip.*"%><%@page import="java.io.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="application/json" pageEncoding="UTF-8"%><%!
    public void addDataSource(DataObject data, String datasources[], SWBScriptEngine eng) throws java.io.IOException
    {
        for(String ds:datasources)
        {
            data.addParam(ds,eng.getDataSource(ds).fetch().getDataObject("response").getDataList("data"));
        }
    }

    public void addAllSources(DataObject data, SWBScriptEngine eng) throws java.io.IOException
    {
        DataObjectIterator it=eng.getDataSource("DataSource").find();
        while (it.hasNext()) {
            DataObject obj = it.next();
            data.addParam(obj.getString("id"),eng.getDataSource(obj.getString("id")).fetch().getDataObject("response").getDataList("data"));
        }
    }
%><%
    try
    {
        SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
        DataObject data=new DataObject();
        String dss[]={"DataSource","DataSourceFields","DataSourceFieldsExt","ValueMapValues","ValueMap","ValidatorExt","Validator","DataService","DataProcessor","PageProps","Page","User"};
        addDataSource(data,dss,eng);
        addAllSources(data,eng);
        
        ZipOutputStream zout=new ZipOutputStream(new FileOutputStream(DataMgr.getApplicationPath()+"/admin/dumpdb.zip"));        
        zout.putNextEntry(new ZipEntry("data.json"));   
        zout.write(data.toString().getBytes(java.nio.charset.Charset.forName("utf8")));
        zout.closeEntry();  
                
        File f=new File(DataMgr.getApplicationPath()+"/uploadfile");
        File upl[]=f.listFiles();
        for(File file:upl)
        {
            zout.putNextEntry(new ZipEntry("uploadfile/"+file.getName()));   
            FileInputStream fin=new FileInputStream(file);
            byte[] bfile = new byte[8192];
            int x;
            while ((x = fin.read(bfile, 0, 8192)) > -1)
            {
                zout.write(bfile, 0, x);
            }
            fin.close();
            zout.closeEntry();              
        }
        zout.close();
        
        out.println(data);
    }catch(java.lang.Exception e){
        e.printStackTrace();
        out.println(e.getMessage());
    }
%>
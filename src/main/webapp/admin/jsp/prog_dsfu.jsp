<%-- 
    Document   : InvTarjetasBancoAzteca
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    DataList getFieldsNames(SWBDataSource ds, boolean folowLinks)
    {
        DataList list=new DataList();
        ScriptObject arr=ds.getDataSourceScript().get("fields");
        if(arr!=null)
        {
            Iterator<ScriptObject> it = arr.values().iterator();
            while (it.hasNext()) {
                ScriptObject obj = it.next();
                String val = obj.getString("name");
                String type = obj.getString("stype");
                String sds= obj.getString("dataSource");
                
                if(folowLinks && type!=null && type.equals("select"))
                {
                    String displayField=ds.getScriptEngine().getDataSource(sds).getDataSourceScript().getString("displayField");
                    if(displayField!=null)val+="."+displayField;
                }
                list.add(val);
            }
        }
        return list;
    }

    String getFieldTitle(String name, SWBDataSource ds)
    {
        int i=name.indexOf('.');
        if(i>-1)
        {
            String base=name.substring(0,i);
            String att=name.substring(i+1);
            String sdsn=ds.getDataSourceScriptField(base).getString("dataSource");
            SWBDataSource sds=ds.getScriptEngine().getDataSource(sdsn);
            return getFieldTitle(att,sds);
        }else
        {
            ScriptObject obj=ds.getDataSourceScriptField(name);
            if(obj!=null)
            {
                return obj.getString("title");
            }else
            {
                return "-";
            }
        }
    }

    String getFieldType(String name, SWBDataSource ds)
    {
        int i=name.indexOf('.');
        if(i>-1)
        {
            String base=name.substring(0,i);
            String att=name.substring(i+1);
            String sdsn=ds.getDataSourceScriptField(base).getString("dataSource");
            SWBDataSource sds=ds.getScriptEngine().getDataSource(sdsn);
            return getFieldType(att,sds);
        }else
        {
            return ds.getDataSourceScriptField(name).getString("type");
        }
    }
    
    DataList getFieldsTitles(Object oheader, SWBDataSource ds) throws IOException
    {
        DataList list=new DataList();
        if(oheader==null)
        {
            return getFieldsTitles(getFieldsNames(ds,false), ds);
        }else if(oheader instanceof DataList)
        {
            Iterator<String>it=((DataList)oheader).iterator();
            while (it.hasNext()) {
                String att = it.next();           
                list.add(getFieldTitle(att, ds));
            }
        }else if(oheader instanceof DataObject)
        {
            Iterator it=((DataObject)oheader).values().iterator();
            while (it.hasNext()) {
                String title = (String)it.next();           
                list.add(title);
            }
        }
        return list;
    }

    DataList getFieldsTypes(Object oheader, SWBDataSource ds) throws IOException
    {
        DataList list=new DataList();
        if(oheader==null)
        {
            return getFieldsTypes(getFieldsNames(ds,false), ds);
        }else if(oheader instanceof DataList)
        {
            Iterator<String>it=((DataList)oheader).iterator();
            while (it.hasNext()) {
                String att = it.next();           
                list.add(getFieldType(att, ds));
            }
        }else if(oheader instanceof DataObject)
        {
            Iterator it=((DataObject)oheader).values().iterator();
            while (it.hasNext()) {
                String title = (String)it.next();           
                list.add(title);
            }
        }
        return list;
    }
%><%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
    
    String tpl=request.getParameter("tpl");
    String id=request.getParameter("id");
    DataObject dataSource=eng.getDataSource("DataSource").getObjectById(id);
    String ds_s=dataSource.getNumId();
    
    if(tpl!=null)
    {
        try
        {
            SWBDataSource ds=eng.getDataSource(ds_s);

            response.setHeader("Content-Disposition","attachment; filename=\""+ds_s+".csv\"");
            response.setContentType("text/csv");

            DataList fields=getFieldsNames(ds,false);
            DataList fieldsTitles=getFieldsTitles(fields,ds);                

            Iterator<String> it=fieldsTitles.iterator();
            while (it.hasNext()) {
                String title = it.next();
                if(title.indexOf(",")>-1)title="\""+title.replace("\"", "\"\"")+"\"";
                out.print(title);
                if(it.hasNext())out.print(",");                
            }
            out.println();    
            
            it=fields.iterator();
            while (it.hasNext()) {
                String title = it.next();
                if(title.indexOf(",")>-1)title="\""+title.replace("\"", "\"\"")+"\"";
                out.print(title);
                if(it.hasNext())out.print(",");                
            }
            out.println();    
            
        }catch(Exception e){
            e.printStackTrace();
        }            
        return;
    }
    
    int j=0;        
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
    System.out.println("isMultipart:"+isMultipart);
    if(isMultipart)
    {   
        SWBDataSource ds=eng.getDataSource(ds_s);
        // Create a factory for disk-based file items
        DiskFileItemFactory factory = new DiskFileItemFactory();

        // Configure a repository (to ensure a secure temp location is used)
        ServletContext servletContext = this.getServletConfig().getServletContext();
        File repository = (File) servletContext.getAttribute("javax.servlet.context.tempdir");
        factory.setRepository(repository);

        // Create a new file upload handler
        ServletFileUpload upload = new ServletFileUpload(factory);

        // Parse the request
        List<FileItem> items = upload.parseRequest(request);
        for(FileItem item:items)
        {
            if (!item.isFormField()) {
                String value = item.getName();
                value = value.replace("\\", "/");
                int pos = value.lastIndexOf("/");
                if (pos > -1) {
                    value = value.substring(pos + 1);
                }
                //item.write(fichero);
                //System.out.println("value:"+value);
                //System.out.println("item 1:"+item);
                //String txt=DataUtils.readInputStream(item.getInputStream());
                //System.out.println("txt:"+txt);     
                
                
                Reader in = new InputStreamReader(item.getInputStream(),"UTF-8");
                CSVRecord dataNames=null;
                CSVRecord dataTitles=null;
                Iterable<CSVRecord> records = CSVFormat.EXCEL.parse(in);
                int i=0;
                for (CSVRecord record : records) {
                    if(i==0)dataTitles=record;
                    else if(i==1)dataNames=record;
                    else if(i>1){
                        try
                        {
                            DataObject obj=new DataObject();
                            for(int x=0;x<record.size();x++)
                            {
                                String fname=dataNames.get(x).trim();
                                if(fname!=null && fname.length()>0)
                                {
                                    ScriptObject field=ds.getScriptField(fname);
                                    if(field.getString("type").equals("int"))
                                    {
                                        obj.addParam(fname, Integer.parseInt(record.get(x).trim()));  
                                    }else if(field.getString("type").equals("long"))
                                    {
                                        obj.addParam(fname, Long.parseLong(record.get(x).trim()));                                
                                    }else if(field.getString("type").equals("double"))
                                    {
                                        obj.addParam(fname, Double.parseDouble(record.get(x).trim()));                                
                                    }else if(field.getString("type").equals("float"))
                                    {
                                        obj.addParam(fname, Float.parseFloat(record.get(x).trim()));                                
                                    }else
                                    {
                                        obj.addParam(fname, record.get(x).trim());  
                                    }
                                }
                            }
                            //out.println(obj);
                            ds.addObj(obj);  
                            j++;
                        }catch(Exception e)
                        {
                            e.printStackTrace();
                        }
                    }
                    i++;
                }
            }
        }
    }
%><!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" /> 
        <title>JSP Page</title>
    </head>
    <body>
        <div class="box-body">
            <div class="col-md-12">
                <h4>Selecciona el archivo CSV a importar...</h4>
                <form method="POST" action="#" enctype="multipart/form-data">
                    <!-- COMPONENT START -->
                    <div class="form-group">
                        <div class="input-group input-file" name="file">
                            <span class="input-group-btn">
                                <button class="btn btn-default btn-choose" type="button">Seleccionar</button>
                            </span>
                            <input type="text" class="form-control" placeholder='Choose a file...' />
                            <span class="input-group-btn">
                                <button class="btn btn-warning btn-reset" type="button">Reiniciar</button>
                            </span>
                        </div>
                    </div>
                    <!-- COMPONENT END -->
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Enviar</button>
                        <!--<button type="reset" class="btn btn-danger">Reset</button>-->
                    </div>                    
                    <%if(j==0){%>
                    <p>El archivo debe de ser formato CSV (valores separados por comas)</p>
                    <p>Puedes descargar la plantilla para la carga <a href="?id=<%=id%>&tpl=true">aqui</a></p>
                    <%}else{%>
                    <p><b>Se agregaron <%=j%> nuevos registros al sistema</b></p>
                    <%}%>
                </form>
            </div>
        </div>        

        <!-- jQuery 2.1.4 -->
        <script src="/static/admin/bower_components/jquery/dist/jquery.min.js"></script>        
        <!-- Bootstrap 3.3.2 JS -->
        <script src="/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>   

        <script type="text/javascript">
            function bs_input_file() {
                $(".input-file").before(
                        function () {
                            if (!$(this).prev().hasClass('input-ghost')) {
                                var element = $("<input type='file' class='input-ghost' style='visibility:hidden; height:0'>");
                                element.attr("name", $(this).attr("name"));
                                element.change(function () {
                                    element.next(element).find('input').val((element.val()).split('\\').pop());
                                });
                                $(this).find("button.btn-choose").click(function () {
                                    element.click();
                                });
                                $(this).find("button.btn-reset").click(function () {
                                    element.val(null);
                                    $(this).parents(".input-file").find('input').val('');
                                });
                                $(this).find('input').css("cursor", "pointer");
                                $(this).find('input').mousedown(function () {
                                    $(this).parents('.input-file').prev().click();
                                    return false;
                                });
                                return element;
                            }
                        }
                );
            }
            $(function () {
                bs_input_file();
            });
        </script>
    </body>
</html>



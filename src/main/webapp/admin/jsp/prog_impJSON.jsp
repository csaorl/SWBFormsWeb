<%-- 
    Document   : InvTarjetasBancoAzteca
    Created on : 10-feb-2019, 20:51:20
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%><%@page import="org.apache.commons.csv.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.apache.commons.fileupload.disk.*"%><%@page import="org.apache.commons.fileupload.servlet.*"%><%@page import="org.apache.commons.fileupload.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
    
    int j=0;        
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
    System.out.println("isMultipart:"+isMultipart);
    if(isMultipart)
    {   
        SWBDataSource ds=null;
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
            System.out.println(item.getFieldName());
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

                BufferedReader in = new BufferedReader(new InputStreamReader(item.getInputStream(),"UTF-8"));
                String line=in.readLine();
                while(line!=null)
                {
                    DataObject obj=(DataObject)DataObject.parseJSON(line);
                    if(obj.containsKey("_id"))obj.addParam("_id", ds.getBaseUri()+obj.getNumId());
                    ds.addObj(obj);
                    //System.out.println(obj);
                    line=in.readLine();
                    j++;
                }
            }else
            {
                if(item.getFieldName().equals("ds"))
                {
                    ds=eng.getDataSource(item.getString());
                }
            }
        }
        return;
    }
%>
        <section class="content-header">
            <h1>Import JSON Data <small></small>
            </h1>
            <ol class="breadcrumb">
                <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
                <li>Programación</li>
                <li><a href="#">Utils</a></li>        
                <li class="active"><a href="#">Import JSON Data</a></li>        
            </ol>
        </section>
        
        <div class="box-body">
            <div class="col-md-12" style="background: white">
                <h4>Importar archivo JSON</h4>
                <form method="POST" action="#" enctype="multipart/form-data">
                    <!-- COMPONENT START -->
                    <div class="form-group">
                    <select name="ds" class="form-control">
<%
    DataObjectIterator it=eng.getDataSource("DataSource").find();
    while (it.hasNext())
    {
        DataObject obj = it.next();
%>                        
                        <option value="<%=obj.getNumId()%>"><%=obj.getNumId()%></option>
<%
    }
%>                        
                    </select>
                    </div>
                    <div class="form-group">
                        <div class="input-group input-file" name="file">
                            <span class="input-group-btn">
                                <button class="btn btn-default btn-choose" type="button">Seleccionar</button>
                            </span>
                            <input type="text" class="form-control" placeholder='Choose a file...' />
                        </div>
                    </div>
                    <!-- COMPONENT END -->
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Enviar</button>
                        <!--<button type="reset" class="btn btn-danger">Reset</button>-->
                    </div>                    
                    <%if(j==0){%>
                    <p>El archivo debe de ser formato JSON</p>
                    <%}else{%>
                    <p><b>Se agregaron <%=j%> nuevos registros al sistema</b></p>
                    <%}%>
                </form>
            </div>
        </div>        

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


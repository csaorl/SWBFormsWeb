<%-- 
    Document   : uml
    Created on : 17-mar-2018, 17:45:33
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!

%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);    
    if(!eng.hasUserRole("prog"))return;
    //System.out.println(obj);
    String _title="JavaScript Console";
    String _smallName="";
    String _fileName=contextPath+"/admin/jsp/prog_jsconsole.jsp";
    
    String seng=request.getParameter("seng");
    String cmd=request.getParameter("cmd");
    if(seng!=null && cmd!=null)
    {
        out.print("<pre>");
        out.println(DataMgr.initPlatform(seng, session).eval(cmd));
        out.print("</pre>");
        return;
    }
    
    //********************************** Ajax Content ************************************************************
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small><%=_smallName%></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programación</li>
        <li class="active"><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
    </ol>
</section>
<!-- Main content -->
<section id="content" style="padding: 7px">  
  <div class="row">
    <div class="col-md-12" id="main_content">    
        <div class="row" style="margin:2px;">            
            <div style="background-color: white;">
                <!-- /.box-header -->
                <div class="box-body">
                    <form class="form-horizontal">                    
                        <!--<h4>JDBC Connection Params</h4>-->
                        <div class="box-body">
                          <div class="form-group">
                              <label for="seng">ScriptEngine</label><input name="seng" class="form-control" type="text"  value="/admin/ds/datasources.js">
                          </div>
                          <div class="form-group">
                              <label for="cmd">Command</label>
                              <input name="cmd" class="form-control" type="text"  value="">
                              <button type="button" class="btn btn-primary" onclick='loadContent("<%=_fileName%>","#result", {seng:form.seng.value,cmd:form.cmd.value})'>Submit</button>
                          </div>
                          <div class="form-group">
                              <label for="res">Result</label><br><div id="result"></div>
                          </div>                          
                        </div>                        
                    </form>                    
                </div>                
            </div>
            <!-- /.box -->                      
        </div> 
    </div><!-- /.col -->
  </div>
</section>
<!-- /.content -->

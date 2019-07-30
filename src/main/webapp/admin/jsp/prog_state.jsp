<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataObject"%>
<%@page import="org.semanticwb.datamanager.DataMgr"%>
<%@page import="org.semanticwb.datamanager.SWBScriptEngine"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String contextPath = request.getContextPath();     
    String _title="Estados";
    String _ds="SWBF_State";
    String _fileName="prog_state";
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    //if(!eng.hasUserPermission(_permision))response.sendError(403,"Acceso Restringido...");

    String id=request.getParameter("id"); 
    boolean iframe=request.getParameter("iframe")!=null; 
    
    DataObject state=eng.getDataSource("SWBF_State").fetchObjById(id);
    DataObject proc=eng.getDataSource("SWBF_Process").fetchObjById(state.getString("process"));
       
    if(!iframe)
    {
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Procesos</li>
        <li><a href="prog_process?id=<%=proc.getId()%>&mode=detail" data-history="#prog_process" data-target=".content-wrapper" data-load="ajax"><%=proc.getString("name")%></a></li>
        <li><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
        <li class="active">Detalle</li>
    </ol>
</section>
<!-- Main content -->
<section id="content" class="content">  
    <div class="row">
        <div class="col-md-12" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#info" data-toggle="tab" aria-expanded="true">Transición</a></li>
                    <!--<li class=""><a href="#tab_2" data-toggle="tab" aria-expanded="false">Fields</a></li>-->
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="info">
                        <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&detail=true&id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
                </div><!-- /.tab-content -->
                <script type="text/javascript">
                    $(window).resize();
                </script>                                                
            </div><!-- nav-tabs-custom -->
        </div><!-- /.col -->
    </div>
</section><!-- /.content -->
<%
    }else 
    {
%>
<!DOCTYPE html>
<html>
    <head>
        <title><%=_title%></title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="<%=contextPath%>/platform/js/eng.js?id=<%=eng.getId()%>" type="text/javascript"></script>
        <link href="<%=contextPath%>/admin/css/sc_admin.css" rel="stylesheet" type="text/css" />
        
        <link rel="stylesheet" href="<%=contextPath%>/static/plugins/codemirror/lib/codemirror.css">
        <link rel="stylesheet" href="<%=contextPath%>/static/plugins/codemirror/addon/hint/show-hint.css">
        <link rel="stylesheet" href="<%=contextPath%>/static/plugins/codemirror/theme/eclipse.css">   
        <link rel="stylesheet" href="<%=contextPath%>/static/plugins/codemirror/addon/dialog/dialog.css">
        <link rel="stylesheet" href="<%=contextPath%>/static/plugins/codemirror/addon/lint/lint.css">          

        <script src="<%=contextPath%>/static/plugins/codemirror/lib/codemirror.js"></script>  
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/hint/show-hint.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/selection/active-line.js"></script> 
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/lint/lint.js"></script>       
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/search/search.js"></script> 
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/search/searchcursor.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/dialog/dialog.js"></script>
                        
        <script src="<%=contextPath%>/static/plugins/codemirror/mode/javascript/javascript.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/hint/javascript-hint.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/lint/javascript-lint.js"></script>
        <script src="//ajax.aspnetcdn.com/ajax/jshint/r07/jshint.js"></script>
                
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/edit/matchbrackets.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/edit/closebrackets.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/comment/continuecomment.js"></script>
        <script src="<%=contextPath%>/static/plugins/codemirror/addon/comment/comment.js"></script>
                
        <script src="<%=contextPath%>/static/plugins/codemirror/mode/clike/clike.js"></script>        
    </head>
    <body>
        <script type="text/javascript">
            eng.initPlatform("/admin/ds/admin.js", <%=eng.getDSCache()%>);
        </script>
        <script type="text/javascript">            
<%            
        if(id!=null)
        {
            String sid = "\"" + id + "\"";
%>
            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                title: "Información",
                showTabs: false,
                canPrint: false,
                numCols: 2,
                colWidths: [250, "*"],
                redrawOnResize:false,
                
                fields: [
                    //{name: "process"},
                    {name: "name"},
                    {name: "description", stype:"text"},
                    //{name: "ds"},        
                    {name: "prop"},        
                    {name: "value"},
                    {name: "processor", height:300},
                    {name: "service", height:300},                    
                    {name: "created"},
                    {name: "creator"},
                    {name: "updated"},
                    {name: "updater"},                    
                ],
                                
                onLoad:function()
                {
                    var req="processor";
                    var res="service";
                    var reqele=document.getElementsByName(req)[0];
                    var resele=document.getElementsByName(res)[0];
                                                            
                    var reqCM = CodeMirror.fromTextArea(reqele, {
                        mode: "text/javascript",                            
                        smartIndent: true,
                        lineNumbers: true,
                        styleActiveLine: true,
                        matchBrackets: true,
                        autoCloseBrackets: true,
                        theme: "eclipse",
                        continueComments: "Enter",
                        extraKeys: {"Ctrl-Space": "autocomplete","Ctrl-Q": "toggleComment","Ctrl-J": "toMatchingTag"},
                        matchTags: {bothTags: true},                  
                        gutters: ["CodeMirror-lint-markers"],
                        lint: true,
                    }); 
                    
                    var resCM = CodeMirror.fromTextArea(resele, {
                        mode: "text/javascript",                            
                        smartIndent: true,
                        lineNumbers: true,
                        styleActiveLine: true,
                        matchBrackets: true,
                        autoCloseBrackets: true,
                        theme: "eclipse",
                        continueComments: "Enter",
                        extraKeys: {"Ctrl-Space": "autocomplete","Ctrl-Q": "toggleComment","Ctrl-J": "toMatchingTag"},
                        matchTags: {bothTags: true},                  
                        gutters: ["CodeMirror-lint-markers"],
                        lint: true,
                    }); 
                    
                    reqCM.on('blur',function(cm){
                        // get value right from instance
                        form.setValue(req,cm.getValue());
                    });
                    
                    resCM.on('blur',function(cm){
                        // get value right from instance
                        form.setValue(res,cm.getValue());
                    });
                    
                    var repaint=function(name,cm){
                        setTimeout(function(){ 
                            var ele=document.getElementsByName(name)[0];
                            ele.style.display = "none";
                            ele.parentNode.insertBefore(cm.getWrapperElement(), ele.nextSibling);
                        },0);
                    };
                    
                    repaint(req,reqCM);
                    repaint(res,resCM);
                                                                
                    window.addEventListener("resize", function(){
                        repaint(req,reqCM);
                        repaint(res,resCM);
                    });                   
                }
                
            }, <%=sid%>, "<%=_ds%>");
            
            form.submitButton.setTitle("Guardar");

            form.submitButton.click = function (p1)
            {
                eng.submit(form, this, function ()
                {
                    isc.say("Datos enviados correctamente...", function () {
                        
                    });
                });
            };

            form.buttons.addMember(isc.IButton.create({
                title: "Regresar",
                padding: "10px",
                click: function (p1) {
                    parent.loadContent("prog_process?mode=detail&id=<%=proc.getId()%>",".content-wrapper");
                    return false;
                }
            }));
            form.buttons.members.unshift(form.buttons.members.pop());
            
<%
        }
%>
        </script>         
    </body>
</html>
<%
    }
%>
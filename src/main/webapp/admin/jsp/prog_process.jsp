<%-- 
    Document   : prog_process
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataMgr"%>
<%@page import="org.semanticwb.datamanager.SWBScriptEngine"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String contextPath = request.getContextPath();     
    String _title="Processes";
    String _ds="SWBF_Process";
    String _fileName="prog_process";
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    //if(!eng.hasUserPermission(_permision))response.sendError(403,"Acceso Restringido...");
    
    String id=request.getParameter("id"); 
    boolean iframe=request.getParameter("iframe")!=null; 
    
    String mode=request.getParameter("mode"); 
    
    //boolean detail=request.getParameter("detail")!=null; 
    //boolean fields=request.getParameter("fields")!=null; 
    //boolean data=request.getParameter("data")!=null; 
    boolean add=(id!=null && id.length()==0);
    
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
        <li>Programación</li>
        <li <%=("detail".equals(mode))?"":"class=\"active\""%>><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
<%
        if("detail".equals(mode))
        {            
%>
        <li class="active"><%=add?"Alta":"Detalle"%></li>
<%
        }
%>        
    </ol>
</section>
<!-- Main content -->
<%
        if("detail".equals(mode))
        {
%>            
<section id="content" class="content">  
    <div class="row">
        <div class="col-md-12" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#info" data-toggle="tab" ondblclick="f_info.src='<%=_fileName%>?iframe=true&mode=detail&id=<%=id%>'"><%=add?"Agregar Proceso":"Información"%></a></li>
<%if(!add){%>
                    <li><a href="#states" data-toggle="tab" ondblclick="f_states.src='<%=_fileName%>?iframe=true&mode=states&id=<%=id%>'" onclick="this.onclick=undefined;this.ondblclick();">Estados</a></li>
                    <li><a href="#transitions" data-toggle="tab" ondblclick="f_transitions.src='<%=_fileName%>?iframe=true&mode=transitions&id=<%=id%>'" onclick="this.onclick=undefined;this.ondblclick();">Transiciones</a></li>
                    <li><a href="#model" data-toggle="tab" ondblclick="f_model.src='uml_process?iframe=true&id=<%=id%>&doc=true'" onclick="this.onclick=undefined;this.ondblclick();">Diagrama</a></li>
<%}%>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="info">
                        <iframe id="f_info" class="ifram_content" src="<%=_fileName%>?iframe=true&mode=detail&id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
<%if(!add){%>
                    <div class="tab-pane" id="states">
                        <iframe id="f_states" class="ifram_content" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
                    <div class="tab-pane" id="transitions">
                        <iframe id="f_transitions" class="ifram_content" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
                    <div class="tab-pane" id="model">
                        <iframe id="f_model" class="ifram_content" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
<%}%>
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
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true" frameborder="0" width="100%">Cargando...</iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>                        
</section><!-- /.content -->
<%
        }
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
    </head>
    <body>
        <script type="text/javascript">
            eng.initPlatform("/admin/ds/admin.js", <%=eng.getDSCache()%>);
        </script>
        <script type="text/javascript">            
<%            
        if(id==null)
        {
%>
            var grid=eng.createGrid({
                //gridType: "TreeGrid",
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: true,
                canAdd: true,
                canRemove: true,
                //showFilter: true,
                //canReorderRecords: true,
                //canAcceptDroppedRecords: true,
                
                showRecordComponents: true,
                showRecordComponentsByCell: true,
                //recordComponentPoolingMode: "recycle",
                fields: [
                    {name: "id", canEdit:false},
                    {name: "name"},
                    {name: "description"},
                    {name: "ds", canEdit:false},
                    {name: "edit", title: " ", width:32, canEdit:false, formatCellValue: function (value) {return " ";}},
                ],

                createRecordComponent: function (record, colNum) {
                    var fieldName = this.getFieldName(colNum);

                    if (fieldName == "edit") {
                        var content=isc.HTMLFlow.create({
                            width:16,
                            //height:16,
                            contents:"<img style=\"cursor: pointer;\" width=\"16\" height=\"16\" src=\"<%=contextPath%>/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                            dynamicContents:true,
                            click: function () {
                                //isc.say(record["_id"] + " info button clicked.");
                                parent.loadContent("<%=_fileName%>?mode=detail&id=" + record["_id"],".content-wrapper");
                                return false;
                            }
                        });
                        return content;
                    } else {
                        return null;
                    }
                },     
 
                addButtonClick: function(event)
                {
                    parent.loadContent("<%=_fileName%>?mode=detail&id=",".content-wrapper");
                    return false;
                },

                
            }, "<%=_ds%>");
<%
        }else if("transitions".equals(mode))
        {
%>
            var grid=eng.createGrid({
                //gridType: "TreeGrid",
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: true,
                canAdd: true,
                canRemove: true,
                //canReorderRecords: true,
                //canAcceptDroppedRecords: true,
                
                showRecordComponents: true,
                showRecordComponentsByCell: true,                
                
                expansionFieldImageShowSelected:true,
                canExpandRecords: true,
                                
                initialCriteria: {"process":"<%=id%>"},
                fields: [
                    {name: "name"},
                    {name: "type"},
                    {name: "sourceStates"},
                    {name: "dateProp"},
                    {name: "edit", title: " ", width:32, canEdit:false, formatCellValue: function (value) {return " ";}},
                ],
                        
                createRecordComponent: function (record, colNum) {
                    var fieldName = this.getFieldName(colNum);

                    if (fieldName == "edit") {
                        var content=isc.HTMLFlow.create({
                            width:16,
                            //height:16,
                            contents:"<img style=\"cursor: pointer;\" width=\"16\" height=\"16\" src=\"<%=contextPath%>/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                            dynamicContents:true,
                            click: function () {
                                //isc.say(record["_id"] + " info button clicked.");
                                parent.loadContent("prog_transi_"+record["type"]+"?id=" + record["_id"],".content-wrapper");
                                return false;
                            }
                        });
                        return content;
                    } else {
                        return null;
                    }
                },                             
                        
                getExpansionComponent : function (record) 
                {
                    var grd=eng.createGrid({
                        height:200,       
                        canEdit: true,
                        canAdd: true,
                        canRemove: true,
                        showFilter: false,
                        editByCell: true,
                        initialCriteria: {"process":record.process, "transition":record._id},
                        fields: [
                            //{name: "process"},
                            //{name: "transition"},
                            {name: "action"},
                            {name: "title"},
                            {name: "states"},
                            {name: "description"},
                            {name: "help"}
                        ],                                               
                    }, "SWBF_TransitionStates");  
                    return grd;
                }                        
                
            }, "SWBF_Transition");    
            
            
            function createWidow(grid)
            {
                var totalsLabel = isc.Label.create({
                    padding: 5,
                    autoDraw:false,
                });

                var mem=[
                    totalsLabel,
                    isc.LayoutSpacer.create({
                        width: "*"
                    })
                ];

                var toolStrip = isc.ToolStrip.create({
                    width: "100%",
                    height: 24,
                    members: mem,
                    autoDraw:false
                });            


                var list=isc.ListGrid.create({
                    width: parent.innerWidth-600, height: parent.innerHeight-300,
                    dataSource: eng.createDataSource("DataSourceFields"),
                    alternateRecordStyles: true,
                    autoFetchData: true,
                    showFilterEditor: true,      
                    canEdit:false,
                    //initialCriteria:{estatus:'ACTIVO'},
                    fields: [
                        {name: "ds"},
                        {name: "name"},
                        {name: "title"},
                        {name: "type"},        
                        {name: "order"},        
                        {name: "required"},                     
                    ]
                });

                list.gridComponents = ["filterEditor","header", "body","summaryRow", toolStrip];

                list.dataChanged = function()
                {
                    this.Super("dataChanged", arguments);
                    var totalRows = this.data.getLength();
                    if (totalRows > 0 && this.data.lengthIsKnown()) {
                        totalsLabel.setContents(totalRows + " Registros");
                    } else {
                        totalsLabel.setContents(" ");
                    }
                };                        

                var addWindow=isc.Window.create({
                    title: "Copiar Propiedad",
                    autoSize:true,
                    autoCenter: true,
                    isModal: true,
                    showModalMask: true,
                    autoDraw: false,
                    closeClick : function () { this.Super("closeClick", arguments)},
                    items: [
                        list, 
                        isc.IButton.create(
                        {
                            title: "Agregar",
                            padding: "10px",
                            click: function(p1) {            
                                
                                var sel=list.getSelectedRecords();   
                                var i=0,r=0;
                                for(var x=0;x<sel.length;x++)
                                {
                                    var oid=sel[x]._id;
                                    console.log(sel[x]);                                    
                                    var obj={ds:"<%=id%>", name:sel[x].name, title:sel[x].title, type:sel[x].type, order:sel[x].order};
                                    if(sel[x].required)obj.required=sel[x].required;
                                    console.log(obj);
                                    
                                    if(eng.getDataSource("DataSourceFields").fetch({data:{ds:obj.ds, name: obj.name}}).totalRows===0)
                                    {
                                        eng.getDataSource("DataSourceFields").addObj(obj);
                                        i++;
                                        var ext=eng.getDataSource("DataSourceFieldsExt").fetch({data:{dsfield:oid}}).data;
                                        console.log(ext);
                                        for(var y=0;y<ext.length;y++)
                                        {
                                            var next={dsfield: obj._id, att: ext[y].att, value: ext[y].value, type: ext[y].type};
                                            eng.getDataSource("DataSourceFieldsExt").addObj(next);      
                                            console.log(next);
                                        }                                        
                                    }else
                                    {
                                        r++;
                                    }
                                }
                                addWindow.hide();
                                list.invalidateCache();
                                grid.invalidateCache();                           
                                isc.confirm(i+" Registros Agregados y "+r+" Registros Repetidos"); 
                                return true;                                    
                            }
                        })
                    ]
                });     
                return addWindow;

            }
            
            var addWindow=createWidow(grid);
            
            var _copyProp = isc.ToolStripButton.create({
                icon: "[SKIN]/actions/configure.png",
                prompt: "Copiar Propiedad",
                autoDraw:false,
                click:function(){
                    addWindow.show();
                    return true;
                }
            });      
            var _toolStrip=grid.getGridMembers()[2];
            _toolStrip.addMember(_copyProp,3);            

<%
        }else if("states".equals(mode))
        {
%>
                var grid=eng.createGrid({
                    autoResize: true,
                    resizeHeightMargin: 20,
                    resizeWidthMargin: 15,
                    canEdit: true,
                    canAdd: true,
                    canRemove: true,
                    showFilter: true,   
                    initialCriteria:{"process":"<%=id%>"},
                    
                    showRecordComponents: true,
                    showRecordComponentsByCell: true,                
                                                
                    fields:[
                        {name: "name"},
                        {name: "description"},
                        {name: "ds"},        
                        {name: "prop"},        
                        {name: "value"},              
                        {name: "edit", title: " ", width:32, canEdit:false, formatCellValue: function (value) {return " ";}},
                    ],                            
                            
                    createRecordComponent: function (record, colNum) {
                        var fieldName = this.getFieldName(colNum);

                        if (fieldName == "edit") {
                            var content=isc.HTMLFlow.create({
                                width:16,
                                //height:16,
                                contents:"<img style=\"cursor: pointer;\" width=\"16\" height=\"16\" src=\"<%=contextPath%>/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                                dynamicContents:true,
                                click: function () {
                                    //isc.say(record["_id"] + " info button clicked.");
                                    parent.loadContent("prog_state?id=" + record["_id"],".content-wrapper");
                                    return false;
                                }
                            });
                            return content;
                        } else {
                            return null;
                        }
                    },                
                
                }, "SWBF_State");    
<%
        }else
        {
            String sid = add?"null":"\"" + id + "\"";
%>
            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                title: "Información",
                showTabs: false,
                canPrint: false,
                numCols: 2,
                colWidths: [250, "*"],
                hasType:function(type)
                {                    
                    var val=this.getValue('type')
                    if(typeof type === "string")
                    {
                        return val && val.startsWith(type);
                    }else if(typeof type === "object")
                    {                        
                        if(val)
                        {
                            //console.log(type);
                            for(var i=0;i<type.length;i++)
                            {                                
                                if(val.startsWith(type[i]))return true;
                            }
                            return false;
                        }                        
                    }
                    return true;
                },
                fields: [
                    {name: "id", change:"form.setValue('scls',value)", <%=!add?"editorType: \"StaticTextItem\", canEdit:false":"required:true"%>},
                    {name: "name", width:"100%"},
                    {name: "description", width:"100%", type:"text"},
                    {name: "ds"},
                    {name: "initTransition"},
<%if(!add){%>                    
                    {name: "created"},
                    {name: "creator"},
                    {name: "updated"},
                    {name: "updater"},
<%}%>                    
                ],

            }, <%=sid%>, "<%=_ds%>");

            form.submitButton.setTitle("Guardar");

            form.submitButton.click = function (p1)
            {
                eng.submit(form, this, function ()
                {
                    isc.say("Datos enviados correctamente...", function () {
                        <%if(add){%>parent.loadContent("<%=_fileName%>?mode=detail&id=" + form.values._id,".content-wrapper");<%}%>
                    });
                });
            };

            form.buttons.addMember(isc.IButton.create({
                title: "Regresar",
                padding: "10px",
                click: function (p1) {
                    parent.loadContent("<%=_fileName%>",".content-wrapper");
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
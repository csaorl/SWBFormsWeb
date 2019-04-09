<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataMgr"%>
<%@page import="org.semanticwb.datamanager.SWBScriptEngine"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String _title="Menus";
    String _ds="Page";
    String _fileName="prog_menus";
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    //if(!eng.hasUserPermission(_permision))response.sendError(403,"Acceso Restringido...");

    String id=request.getParameter("id"); 
    boolean iframe=request.getParameter("iframe")!=null; 
    boolean detail=request.getParameter("detail")!=null; 
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
        <li><a href="/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programación</li>
        <li <%=detail?"":"class=\"active\""%>><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
<%
        if(detail)
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
        if(detail)
        {
%>            
<section id="content" class="content">  
    <div class="row">
        <div class="col-md-12" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#info" data-toggle="tab" aria-expanded="true"><%=add?"Agregar Menu":"Información"%></a></li>
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
        <script src="/platform/js/eng.js?id=<%=eng.getId()%>" type="text/javascript"></script>
        <link href="/admin/css/sc_admin.css" rel="stylesheet" type="text/css" />
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
            eng.createGrid({
                gridType: "TreeGrid",
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: true,
                canAdd: true,
                canRemove: true,
                //showFilter: true,
                canReorderRecords: true,
                canAcceptDroppedRecords: true,
                
                sortField: "order",
                //sortDirection: "descending",
                
                appImgDir:"/admin/images/",
                
                showRecordComponents: true,
                showRecordComponentsByCell: true,
                //recordComponentPoolingMode: "recycle",
                fields: [
                    //{name: "id"},
                    {name: "name"},
                    //{name: "parentId"},
                    {name: "smallName"},
                    {name: "type", width:110},
                    {name: "iconClass", width:110},
                    {name: "order", width:70},
                    {name: "roles_view"},
                    {name: "status", width:70},
                    //{name: "roles_add"},
                    //{name: "roles_update"},
                    //{name: "roles_remove"},
                    //{name: "ds"},
                    //{name: "created"},
                    //{name: "creator"},
                    //{name: "updated"},
                    //{name: "updater"},
                    {name: "edit", title: " ", width:32, canEdit:false, formatCellValue: function (value) {return " ";}},
                ],
                
                dataProperties:{
                    loadDataOnDemand:false,
                    dataArrived:function (parentNode) {
                        this.openAll();
                    }
                },

                createRecordComponent: function (record, colNum) {
                    var fieldName = this.getFieldName(colNum);

                    if (fieldName == "edit") {
                        var content=isc.HTMLFlow.create({
                            width:16,
                            //height:16,
                            contents:"<img style=\"cursor: pointer;\" width=\"16\" height=\"16\" src=\"/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                            dynamicContents:true,
                            click: function () {
                                //isc.say(record["_id"] + " info button clicked.");
                                parent.loadContent("<%=_fileName%>?detail=true&id=" + record["_id"],".content-wrapper");
                                return false;
                            }
                        });
                        return content;
                    } else {
                        return null;
                    }
                },     
/*                
                updateRecordComponent: function (record, colNum, component, recordChanged) {
                    var fieldName = this.getFieldName(colNum);
                    if (fieldName == "edit") {
                        component.addProperties({                     
                            width:16,
                            height:16,
                        });
                    } else {
                        return null;
                    }
                    return component;
                },                                          
*/                
                addButtonClick: function(event)
                {
                    parent.loadContent("<%=_fileName%>?detail=true&id=",".content-wrapper");
                    return false;
                },

                
            }, "<%=_ds%>");
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
                        return val && val.indexOf(type)>-1;
                    }else if(typeof type === "object")
                    {                        
                        if(val)
                        {
                            //console.log(type);
                            for(var i=0;i<type.length;i++)
                            {                                
                                if(val.indexOf(type[i])>-1)return true;
                            }                            
                        }    
                        return false;
                    }
                    return true;
                },
                
                fields: [
                    {name: "id", <%=!add?"editorType: \"StaticTextItem\", canEdit:false":"required:true"%>},
                    {name: "name", width:"100%"},
                    {name: "parentId"},
                    {name: "smallName", width:"100%"},
                    {name: "order", width:70},
                    {name: "urlParams", width:"100%"},
                    {name: "type", redrawOnChange:true},
                    {name: "icon"},
                    {name: "iconClass"},
                    {name: "roles_view", width:"100%"},
                    {name: "status"},                    
                    {name: "path", width:"100%", showIf:"form.hasType(['ajax','iframe','url'])"},
                    {name: "ds", showIf:"form.hasType('sc')"},
                    {name: "gd_conf", showIf:"form.hasType('sc_grid_detail')"},
                    {name: "gridProps", width:"100%", showIf:"form.hasType('sc_grid')"},
                    {name: "gridExtProps", width:"100%", showIf:"form.hasType('sc_grid')", editByCell:true,
                        getEditorProperties:function(editField, editedRecord, rowNum) {
                            if (editField.name == "value")
                            {
                                if(editedRecord!=null) {
                                    var item=ds_field_atts_vals[editedRecord.att];
                                    editField._lastItem=item;
                                    //console.log(item);                                    
                                    return item;
                                }else
                                {
                                    return editField._lastItem;
                                }
                            } 
                            return null;
                        }, 
                    },
                    {name: "gridAddiJS", showIf:"form.hasType('sc_grid')"},
                    {name: "formProps", width:"100%", showIf:"form.hasType(['sc_grid_detail','sc_form'])"},
                    {name: "formExtProps", width:"100%", showIf:"form.hasType(['sc_grid_detail','sc_form'])", editByCell:true,
                        getEditorProperties:function(editField, editedRecord, rowNum) {
                            if (editField.name == "value")
                            {
                                if(editedRecord!=null) {
                                    var item=ds_field_atts_vals[editedRecord.att];
                                    editField._lastItem=item;
                                    //console.log(item);                                    
                                    return item;
                                }else
                                {
                                    return editField._lastItem;
                                }
                            } 
                            return null;
                        }, 
                    },
                    {name: "formAddiJS", showIf:"form.hasType(['sc_grid_detail','sc_form'])"},
                    {name: "roles_add", width:"100%", showIf:"form.hasType('sc')"},
                    {name: "roles_update", width:"100%", showIf:"form.hasType('sc')"},
                    {name: "roles_remove", width:"100%", showIf:"form.hasType('sc')"},
<%if(!add){%>                    
                    {name: "created"},
                    {name: "creator"},
                    {name: "updated"},
                    {name: "updater"},
<%}%>   
                ],
          
                onLoad:function()
                {
                    //Bug al mostrar segundo select, em ocasiones se queda bloqueado cargando
                    setTimeout(function()
                    {
                        var i=form.getItem("formProps");
                        if(i.isVisible())
                        {
                            i.hide();
                            setTimeout(function(){i.show();},0);
                        }
                    },0);
                    setTimeout(function(){
                        parent.$(".ifram_content").attr("height", (document.body.offsetHeight+60) + "px");
                    },100);                    
                }

            }, <%=sid%>, "<%=_ds%>");

            form.submitButton.setTitle("Guardar");

            form.submitButton.click = function (p1)
            {
                eng.submit(form, this, function ()
                {
                    isc.say("Datos enviados correctamente...", function () {
                        <%if(add){%>parent.loadContent("<%=_fileName%>?detail=true&id=" + form.values._id,".content-wrapper");<%}%>
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
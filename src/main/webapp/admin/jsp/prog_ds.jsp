<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataMgr"%>
<%@page import="org.semanticwb.datamanager.SWBScriptEngine"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String _title="DataSources";
    String _ds="DataSource";
    String _fileName="prog_ds";
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
        <li><a href="/admin"><i class="fa fa-home"></i>Home</a></li>
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
                    <li class="active"><a href="#info" data-toggle="tab"><%=add?"Agregar Menu":"Información"%></a></li>
<%if(!add){%>
                    <li><a href="#fields" data-toggle="tab">Propiedades</a></li>
                    <li><a href="#data" data-toggle="tab">Datos</a></li>
                    <li><a href="#import" data-toggle="tab">Importar</a></li>
<%}%>
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="info">
                        <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&mode=detail&id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
<%if(!add){%>
                    <div class="tab-pane" id="fields">
                        <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&mode=fields&id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
                    <div class="tab-pane" id="data">
                        <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&mode=data&id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
                    </div><!-- /.tab-pane -->
                    <div class="tab-pane" id="import">
                        <iframe class="ifram_content" src="prog_dsfu?id=<%=id%>" frameborder="0" width="100%">Cargando...</iframe>
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
            var grid=eng.createGrid({
                //gridType: "TreeGrid",
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: true,
                canAdd: true,
                canRemove: true,
                //showFilter: true,
                canReorderRecords: true,
                canAcceptDroppedRecords: true,
                
                showRecordComponents: true,
                showRecordComponentsByCell: true,
                //recordComponentPoolingMode: "recycle",
                fields: [
                    {name: "id", canEdit:false},
                    {name: "description"},
                    {name: "backend"},
                    {name: "frontend"},        
                    {name: "roles_fetch"},
                    {name: "roles_add"},
                    {name: "roles_update"},
                    {name: "roles_remove"},   
                    
                    {name: "edit", title: " ", width:32, canEdit:false, formatCellValue: function (value) {return " ";}},
                ],

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
        }else if("fields".equals(mode))
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
                canReorderRecords: true,
                canAcceptDroppedRecords: true,
                
                expansionFieldImageShowSelected:true,
                canExpandRecords: true,
                
                canSort: false, // Disable user sorting because we rely on records being sorted by userOrder.
                sortField: "order",
                
                initialCriteria: {"ds":"<%=id%>"},
                fields: [
                    //{name: "ds"},
                    {name: "name"},
                    {name: "title"},
                    {name: "type"},        
                    {name: "required"},
                    {name: "order", width:70},
                ],
                        
                getExpansionComponent : function (record) 
                {
                    var grd=eng.createGrid({
                        height:200,       
                        canEdit: true,
                        canAdd: true,
                        canRemove: true,
                        showFilter: false,
                        editByCell: true,
                        initialCriteria: {"dsfield":record._id},
                        fields: [
                            //{name: "dsfield"},
                            {name: "att"},
                            {name: "type"},
                            {name: "value"},
                        ],
                        getEditorProperties:function(editField, editedRecord, rowNum) {
                            //console.log("getEditorProperties",this,this.getSelectedRecord().type,editField,editedRecord,rowNum);
                            if (editField.name == "value")
                            {
                                if(editedRecord!=null) {
                                    var item=ds_field_atts_vals[editedRecord.att];                                     
                                    var act=this.getSelectedRecord();
                                    if(act)
                                    {
                                        if(item.type!=act.type)
                                        {
                                            item.type=act.type;
                                        }
                                    }                                    
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
                    }, "<%=_ds%>FieldsExt");  
                    return grd;
                }                        
                
            }, "<%=_ds%>Fields");    
            
            
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
        }else if("data".equals(mode))
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
                }, "<%=id.substring(id.lastIndexOf(":") + 1)%>");    
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
                    {name: "description", width:"100%", type:"text"},
                    {name: "scls"},
                    {name: "modelid", hint:"_modelid", showHintInField:true},
                    {name: "dataStore", hint:"_dataStore", showHintInField:true},
                    {name: "displayField"},
                    //{name: "valueField"},
                    //{name: "sortField"},
                    {name: "backend"},
                    {name: "frontend"},        
                    {name: "roles_fetch", width:"100%"},
                    {name: "roles_add", width:"100%"},
                    {name: "roles_update", width:"100%"},
                    {name: "roles_remove", width:"100%"},                     
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
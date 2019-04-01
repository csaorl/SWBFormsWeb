<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.DataMgr"%>
<%@page import="org.semanticwb.datamanager.SWBScriptEngine"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%
    String _title="Validator";
    String _ds="Validator";
    String _fileName="prog_valid";
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    //if(!eng.hasUserPermission(_permision))response.sendError(403,"Acceso Restringido...");
    
    boolean iframe=request.getParameter("iframe")!=null; 
    
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
        <li class="active"><%=_title%></li>
    </ol>
</section>
<!-- Main content -->

<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true" frameborder="0" width="100%">Cargando...</iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>                        
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
        <script src="/platform/js/eng.js?id=<%=eng.getId()%>" type="text/javascript"></script>
        <link href="/admin/css/sc_admin.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
        <script type="text/javascript">
            eng.initPlatform("/admin/ds/admin.js", <%=eng.getDSCache()%>);
        </script>
        <script type="text/javascript">            
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
                
                //canSort: false, // Disable user sorting because we rely on records being sorted by userOrder.
                //sortField: "order",
                
                fields: [
                    {name: "id"},
                    //{name: "name"},
                    {name: "type"},        
                    {name: "errorMessage"},
                    {name: "description"},
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
                        initialCriteria: {"validator":record._id},
                        fields: [
                            //{name: "validator"},
                            {name: "att"},
                            {name: "type"},
                            {name: "value"},
                        ],
                        getEditorProperties:function(editField, editedRecord, rowNum) {
                            //console.log("getEditorProperties",this,this.getSelectedRecord().type,editField,editedRecord,rowNum);
                            if (editField.name == "value")
                            {
                                if(editedRecord!=null) {
                                    var item=ds_validator_atts_vals[editedRecord.att];                                     
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
                    }, "<%=_ds%>Ext");  
                    return grd;
                }                        
                
            }, "<%=_ds%>");    
        </script>         
    </body>
</html>
<%
    }
%>
<%-- 
    Document   : prog_menu
    Created on : 10-feb-2018, 19:57:02
    Author     : javiersolis
--%><%@page import="org.semanticwb.datamanager.script.ScriptObject"%>
<%@page import="java.io.IOException"%><%@page import="java.util.Iterator"%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!

    public String parseScript(String txt, HttpServletRequest request, DataObject user)
    {
        if(txt==null)return "";    

        Iterator it=DataUtils.TEXT.findInterStr(txt, "{$getParameter:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("'") && k.endsWith("'")))k=k.substring(1,k.length()-1);
            String replace=request.getParameter(k);
            if(replace!=null)txt=txt.replace("{$getParameter:"+s+"}", replace);
        }

        it=DataUtils.TEXT.findInterStr(txt, "{$user:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("'") && k.endsWith("'")))k=k.substring(1,k.length()-1);
            String replace=user.getString(k);
            txt=txt.replace("{$user:"+s+"}", replace);
        }
        return txt;
    }
    
    public DataList getExtProps(DataObject obj, String extPropsField, SWBScriptEngine eng) throws IOException
    {
        DataList extProps=new DataList();
        DataList data=obj.getDataList(extPropsField);
        if(data!=null)
        {
            DataObject query=new DataObject();
            query.addSubObject("data").addParam("_id", data);
            extProps=eng.getDataSource("PageProps").fetch(query).getDataObject("response").getDataList("data");
        }
        return extProps;
    }

    public StringBuilder getProps(DataList extProps, HttpServletRequest request, DataObject user)
    {
        StringBuilder fields=new StringBuilder();
        DataList empty=new DataList();
        for(int i=0;i<extProps.size();i++)
        {
            DataObject ext=extProps.getDataObject(i);
            if(ext.getDataList("prop",empty).isEmpty())
            {
                String att=ext.getString("att");
                String value=parseScript(ext.getString("value"),request,user);
                String type=ext.getString("type");
                fields.append(att+":");
                if("string".equals(type) || "date".equals(type))
                {
                    fields.append("\""+value+"\"");
                }else
                {
                    fields.append(value);
                }
                fields.append(",\n");
            }
        }
        return fields;
    }    

    public StringBuilder getFields(DataObject obj, String propsField, DataList extProps, SWBScriptEngine eng)
    {
        StringBuilder fields=new StringBuilder();
        DataList gridProps=obj.getDataList(propsField);
        DataList empty=new DataList();
        if(gridProps!=null)
        {
            Iterator<String> it=gridProps.iterator();
            while (it.hasNext()) {
                String _id = it.next();
                String name=_id.substring(_id.indexOf(".")+1);
                //System.out.println(_id);
                fields.append("{");
                fields.append("name:"+"\""+name+"\"");
                for(int i=0;i<extProps.size();i++)
                {
                    DataObject ext=extProps.getDataObject(i);
                    if(ext.getDataList("prop",empty).contains(_id))
                    {
                        String att=ext.getString("att");
                        if(att.equals("canEditRoles")) {
                            //System.out.println("canEditRoles:"+ext.getString("value"));
                            boolean enabled = eng.hasUserAnyRole(ext.getString("value").split(","));
                            fields.append(", disabled:"+!enabled);
                        }else if(att.equals("canViewRoles")) {
                            boolean visible = eng.hasUserAnyRole(ext.getString("value").split(","));
                            fields.append(", visible:"+visible);
                        }else {
                            // original
                            String value=ext.getString("value");
                            String type=ext.getString("type");
                            fields.append(", "+att+":");
                            if("string".equals(type) || "date".equals(type))
                            {
                                fields.append("\""+value+"\"");
                            }else
                            {
                                fields.append(value);
                            }
                            // fin. original
                        }
                    }
                }
                fields.append("}");
                if(it.hasNext())fields.append(",");
                fields.append("\n");
            }
        }    
        return fields;
    }

    String getParentPath(DataObject page, SWBScriptEngine eng) throws IOException
    {
        StringBuilder ret=new StringBuilder();
        String parentId=page.getString("parentId");
        if(parentId!=null)
        {
            DataObject obj=eng.getDataSource("Page").getObjectById(parentId);   
            String title=obj.getString("name","");
            //String smallName=obj.getString("smallName","");
            String path=obj.getString("path");
            String iconClass=obj.getString("iconClass");
            if(iconClass==null)iconClass="fa fa-circle-o";
            String type=obj.getString("type");
            
            if("sc_grid".equals(type))path="admin_content?pid="+obj.getNumId();
            if("sc_grid_detail".equals(type))path="admin_content?pid="+obj.getNumId();
            if("sc_form".equals(type))path="admin_content?pid="+obj.getNumId();
            if("iframe_content".equals(type))path="admin_content?pid="+obj.getNumId();
            if("ajax_content".equals(type))path="admin_content?pid="+obj.getNumId();            
            
            if(type!=null && !type.equals("head"))
            {
                ret.append(getParentPath(obj,eng));
                ret.append("<li>");
                if(path!=null)ret.append("<a href=\""+path+"\">");
                //if(iconClass!=null)ret.append("<i class=\""+iconClass+"\"></i> ");
                ret.append(title);
                if(path!=null)ret.append("</a>");
                ret.append("</li>");
            }
        }
        return ret.toString();
    }

%><%
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user=eng.getUser();
    
    String pid=request.getParameter("pid");
    boolean iframe=request.getParameter("iframe")!=null; 
    boolean aiframe=request.getParameter("aiframe")!=null; 
    boolean detail=request.getParameter("detail")!=null;
    String id=request.getParameter("id");    
    String rid=request.getParameter("rid");    
    
    DataObject obj=eng.getDataSource("Page").getObjectByNumId(pid);   
    //System.out.println(obj);
    String _title=obj.getString("name","");
    String _smallName=obj.getString("smallName","");
    String _ds=obj.getString("ds");
    String _path=obj.getString("path","");
    String _fileName="admin_content";
    DataList gd_conf=obj.getDataList("gd_conf",new DataList());
    String type=obj.getString("type");
    
    if(id!=null && _path.length()>0)
    {
        _path=_path.replace("{id}", id);
        String sid[]=id.split(":");
        if(sid.length==4)_path=_path.replace("{ID}", sid[3]);    
    }

    if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))response.sendError(403,"Acceso Restringido...");
    
    //ajax iframe
    if(aiframe)
    {
        if("sc_form".equals(type))
        {
%>
        <iframe class="ifram_content <%=pid%>" src="<%=_fileName%>?pid=<%=pid%>&iframe=true<%=(rid!=null)?("&rid="+rid):""%>&id=<%=id%>" frameborder="0" width="100%"></iframe>     
<%
        }else if(type.startsWith("sc_grid"))
        {
%>
        <iframe class="ifram_content <%=pid%>" src="<%=_fileName%>?pid=<%=pid%>&iframe=true&rid=<%=id%>" frameborder="0" width="100%"></iframe>
<%
        }else if("iframe_content".equals(type))
        {
%>
        <iframe class="ifram_content <%=pid%>" src="<%=_path%>" frameborder="0" width="100%"></iframe>
<%
        }
%>
        <script type="text/javascript">
            $(window).resize();
        </script>
<%
        return;
    }
        
    if("sc_form".equals(type))
    {
        if(id==null)id="";
    }
    boolean add=(id!=null && id.length()==0);   
    
    StringBuilder fields;
    DataList extProps;
    if(id==null)
    {
        extProps=getExtProps(obj,"gridExtProps",eng);
        fields=getFields(obj, "gridProps", extProps, eng);
    }else
    {
        extProps=getExtProps(obj,"formExtProps",eng);
        fields=getFields(obj, "formProps", extProps, eng);
    }
    
    if(!iframe)
    {
        //********************************** Ajax Content ************************************************************
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small><%=_smallName%></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="/admin"><i class="fa fa-home"></i>Home</a></li>
        <%=getParentPath(obj,eng)%>
        <li class="active"><a href="<%=_fileName%>?pid=<%=obj.getNumId()%>" data-history="#<%=obj.getNumId()%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
<%
    if(id!=null && id.length()>0)
    {
        DataObject objd=eng.getObjectById(id);
        if(objd!=null)
        {
            String name=objd.getNumId();
            String df=eng.getDataSource(objd.getClassName()).getDisplayField();
            if(df!=null)name=objd.getString(df);
%>
        <li class="active"><%=name%></li>
<%           
        }
    }
%>        
    </ol>
</section>
<!-- Main content -->
<% 
        if(id==null)
        {
%>
<section id="content" style="padding: 7px">  
<%
            if(type.equals("iframe_content"))
            {
%>    
    <iframe class="ifram_content" src="<%=_path%>" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>            
<%
            }else if(type.equals("ajax_content"))
            {
%>    
    <script type="text/javascript">
        loadContent("<%=_path%>","#content");
    </script>            
<%
            }else if(type.startsWith("sc"))
            {
%>
    <iframe class="ifram_content <%=pid%>" src="<%=_fileName%>?pid=<%=pid%>&iframe=true" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>                        
<%
            }
%>
</section>
<%
        }else
        { 
            DataObject query=new DataObject();
            query.addSubList("sortBy").add("order");
            query.addSubObject("data").addParam("parentId", obj.getId());
            DataList childs=eng.getDataSource("Page").fetch(query).getDataObject("response").getDataList("data");      
            //System.out.println("child:"+childs);
%>
<section id="content" class="content">  
    <div class="row">
        <div class="col-md-12" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#info" data-toggle="tab" aria-expanded="true"><%=add?"Agregar "+_title:"Información"%></a></li>                                        
<%
            Iterator<DataObject> it=childs.iterator();
            while (it.hasNext()) {
                DataObject tab = it.next();       
                String tabType=tab.getString("type");
                if("ajax_content".equals(tabType))
                {
                    String tabPath=tab.getString("path","");
                    //replace special args
                    tabPath=tabPath.replace("{id}", id);
                    String sid[]=id.split(":");
                    if(sid.length==4)tabPath=tabPath.replace("{ID}", sid[3]);
%>
                    <li class=""><a href="#<%=tab.getNumId()%>" data-toggle="tab" aria-expanded="false" ondblclick="loadContent('<%=tabPath%>','#<%=tab.getNumId()%>')" onclick="this.onclick=undefined;this.ondblclick();"><%=tab.getString("name")%></a></li>
<%                    
                }else
                {
%>
                    <li class=""><a href="#<%=tab.getNumId()%>" data-toggle="tab" aria-expanded="false" ondblclick="loadContent('<%=_fileName%>?pid=<%=tab.getNumId()%>&aiframe=true&id=<%=id%>','#<%=tab.getNumId()%>')" onclick="this.onclick=undefined;this.ondblclick();"><%=tab.getString("name")%></a></li>
<%
                }
            }            
%>                    
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="info">
                        <iframe class="ifram_content <%=pid%>" src="<%=_fileName%>?pid=<%=pid%>&iframe=true<%=(rid!=null)?("&rid="+rid):""%>&id=<%=id%>" frameborder="0" width="100%"></iframe>
                    </div><!-- /.tab-pane -->
<%
            it=childs.iterator();
            while (it.hasNext()) {
                DataObject tab = it.next();     
                //System.out.println("tab:"+tab.getNumId()+" "+id);
%>
                <div class="tab-pane" id="<%=tab.getNumId()%>"><center>Loading...</center></div><!-- /.tab-pane -->
<%
            }            
%>                    
                </div><!-- /.tab-content -->
                <script type="text/javascript">
                    $(window).resize();
                </script>                                                
            </div><!-- nav-tabs-custom -->
        </div><!-- /.col -->
    </div>
</section>
<%
        }
%>
<!-- /.content -->
<%
        //********************************** End Ajax ************************************************************
    }else 
    {
        //********************************** IFrame Content ************************************************************
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
            eng.initPlatform("/admin/ds/datasources.js", <%=eng.getDSCache()%>);
        </script>
        <script type="text/javascript">
<%        
        if(id==null)
        {
            //********************************** Grid ************************************************************
%>            
            var grid=eng.createGrid({
                autoResize: true,
                resizeHeightMargin: 20,
                resizeWidthMargin: 15,
                canEdit: <%=eng.hasUserAnyRole(obj.getDataList("roles_update"))%>,
                canAdd: <%=eng.hasUserAnyRole(obj.getDataList("roles_add"))%>,
                canRemove: <%=eng.hasUserAnyRole(obj.getDataList("roles_remove"))%>,
                showFilter: true,         
                <%=getProps(extProps,request,user)%>
<%
            if(rid!=null)
            {
                DataObject pobj=eng.getDataSource("Page").getObjectById(obj.getString("parentId"));
                String psds=pobj.getString("ds");
                String sds=obj.getString("ds");
                Iterator<ScriptObject> it=eng.getDataSource(sds).findScriptFields("dataSource", psds).iterator();
                String name=null;
                if (it.hasNext()) {
                    ScriptObject field = it.next();
                    name=field.getString("name");
                }
                if(name!=null)
                {
                    out.println("                initialCriteria: {'"+name+"':'"+rid+"'}, ");
                }
            }
            if("sc_grid_detail".equals(type))
            {
                if(gd_conf.contains("inlineEdit"))
                {
                    fields.append(",{name: \"edit\", title: \" \", width:32, canEdit:false, formatCellValue: function (value) {return \" \";}}");
%>
                showRecordComponents: true,
                showRecordComponentsByCell: true,
                //recordComponentPoolingMode: "recycle",
                
                createRecordComponent: function (record, colNum) {
                    var fieldName = this.getFieldName(colNum);
                    
                    if (fieldName == "edit") {
                        var content=isc.HTMLFlow.create({
                            width:32,
                            height:16,
                            contents:"<img style=\"cursor: pointer; padding: 5px 11px;\" width=\"16\" height=\"16\" src=\"/platform/isomorphic/skins/Tahoe/images/actions/edit.png\">", 
                            //dynamicContents:false,
                            click: function () {
                                parent.loadContent("<%=_fileName%>?pid=<%=pid%>&id=" + record["_id"],".content-wrapper");
                                return false;
                            }
                        });
                        return content;
                    } else {                    
                        return null;
                    }
                },                     
<%        
                }else
                {
%>                  
                recordDoubleClick: function(grid, record)
                {
                    parent.loadContent("<%=_fileName%>?pid=<%=pid%><%=(rid!=null)?("&rid="+rid):""%>&id="+ record["_id"],".content-wrapper");
                    return false;
                },
<%
                }
                if(!gd_conf.contains("inlineAdd"))
                {
%>                
                addButtonClick: function(event)
                {
                    parent.loadContent("<%=_fileName%>?pid=<%=pid%><%=(rid!=null)?("&rid="+rid):""%>&id=",".content-wrapper");
                    return false;
                },                                 
<%
                }
            }
%>                
                fields: [<%=fields%>]           
            }, "<%=_ds%>");
            
            <%=parseScript(obj.getString("gridAddiJS"),request,user)%>
<%
            //********************************** End Grid ************************************************************    
        }else
        {
            //********************************** Form ************************************************************
            String sid = add?"null":"\"" + id + "\"";
%>
            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                title: "Información",
                showTabs: false,
                canPrint: false,
                canEdit: <%=eng.hasUserAnyRole(obj.getDataList("roles_update"))%>,
                numCols: 2,
                colWidths: [250, "*"],
                <%=getProps(extProps,request,user)%>
                fields: [<%=fields%>],
                onLoad:function()
                {
                    setTimeout(function(){
                        parent.$(".<%=pid%>").attr("height", (document.body.offsetHeight+16) + "px");
                    },0);
                }
            }, <%=sid%>, "<%=_ds%>");

            form.submitButton.setTitle("Guardar");

            form.submitButton.click = function (p1)
            {
                eng.submit(form, this, function ()
                {
                    isc.say("Datos enviados correctamente...", function () {
                        <%if(add){%>parent.loadContent("<%=_fileName%>?pid=<%=pid%><%=(rid!=null)?("&rid="+rid):""%>&id=" + form.values._id,".content-wrapper");<%}%>
                    });
                });
            };

            form.buttons.addMember(isc.IButton.create({
                title: "Regresar",
                padding: "10px",
                click: function (p1) {
                    parent.loadContent("<%=_fileName%>?pid=<%=pid%><%=(rid!=null)?("&rid="+rid):""%>",".content-wrapper");
                    return false;
                }
            }));
            form.buttons.members.unshift(form.buttons.members.pop());  
            
            <%=parseScript(obj.getString("formAddiJS"),request,user)%>
<%
            //********************************** End Form ************************************************************    
        }
%>    
        </script>         
    </body>
</html>
<%
        //********************************** Enf IFrame Content ************************************************************

    }
%>
<%-- 
    Document   : admin_process
    Created on : 23-jul-2019, 19:15:05
    Author     : javiersolis
--%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%!

    public String parseScript(String txt, HttpServletRequest request, DataObject user)
    {
        if(txt==null)return "";    

        Iterator it=DataUtils.TEXT.findInterStr(txt, "{$getParameter:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("\"") && k.endsWith("\"")))k=k.substring(1,k.length()-1);
            String replace=request.getParameter(k);
            if(replace==null)replace="";
            txt=txt.replace("{$getParameter:"+s+"}", replace);
        }

        it=DataUtils.TEXT.findInterStr(txt, "{$user:", "}");
        while(it.hasNext())
        {
            String s=(String)it.next();
            String k=s.trim();
            if((k.startsWith("'") && k.endsWith("'")) || (k.startsWith("\"") && k.endsWith("\"")))k=k.substring(1,k.length()-1);
            String replace=user.getString(k,"");
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
                boolean add=true;
                StringBuilder row=new StringBuilder();
                row.append("{");
                row.append("name:"+"\""+name+"\"");
                for(int i=0;i<extProps.size();i++)
                {
                    DataObject ext=extProps.getDataObject(i);
                    if(ext.getDataList("prop",empty).contains(_id))
                    {
                        String att=ext.getString("att");
                        if(att.equals("canEditRoles")) {
                            //System.out.println("canEditRoles:"+ext.getString("value"));
                            boolean enabled = eng.hasUserAnyRole(ext.getString("value").split(","));
                            row.append(", disabled:"+!enabled);
                        }else if(att.equals("canViewRoles")) {
                            boolean visible = eng.hasUserAnyRole(ext.getString("value").split(","));
                            row.append(", visible:"+visible);
                            add=visible;
                        }else {
                            // original
                            String value=ext.getString("value");
                            String type=ext.getString("type");
                            row.append(", "+att+":");
                            if("string".equals(type) || "date".equals(type))
                            {
                                row.append("\""+value+"\"");
                            }else
                            {
                                row.append(value);
                            }
                            // fin. original
                        }
                    }
                }
                row.append("}");
                if(it.hasNext())row.append(",");
                if(add)fields.append(row);
                fields.append("\n");
            }
        }    
        return fields;
    }

%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user=eng.getUser();
    
    String pid=request.getParameter("pid");
    String id=request.getParameter("id");
    String itrn=request.getParameter("itrn");
    boolean iframe=request.getParameter("iframe")!=null;   
    
    DataObject opage=eng.getDataSource("Page").getObjectByNumId(pid);
    DataObject transition=eng.getDataSource("SWBF_Transition").fetchObjByNumId(itrn);
    
    String sid = id==null?"null":"\"" + id + "\"";
    
    if(!iframe)
    {
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=opage.getString("name")%>
        <small></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>        
        <li><a href="admin_content?pid=<%=pid%>" data-history="#<%=pid%>" data-target=".content-wrapper" data-load="ajax"><%=opage.getString("name")%></a></li>        
        <li class="active"><a href="#"><%=transition.getString("name")%></a></li>        
    </ol>
</section>
<!-- Main content -->

<section id="content" class="content">  
    <div class="row">
        <div class="col-md-12" id="main_content">
            <!-- Custom Tabs -->
            <div class="nav-tabs-custom">
                <ul class="nav nav-tabs">
                    <li class="active"><a href="#info" data-toggle="tab" aria-expanded="true"><%=transition.getString("name")%></a></li>                                        
                    
                </ul>
                <div class="tab-content">
                    <div class="tab-pane active" id="info">
                        <iframe class="ifram_content <%=pid%>" src="admin_process?itrn=<%=itrn%>&pid=<%=pid%>&iframe=true<%=(id!=null)?("&id="+id):""%>" frameborder="0" width="100%"></iframe>
                    </div><!-- /.tab-pane -->                    
                </div><!-- /.tab-content -->
                <script type="text/javascript">
                    $(window).resize();
                </script>                                                
            </div><!-- nav-tabs-custom -->
        </div><!-- /.col -->
    </div>
</section>
<!-- /.content -->
<%
    }else
    {
        DataList extProps=getExtProps(transition,"formExtProps",eng);
        StringBuilder fields=getFields(transition, "formProps", extProps, eng);
%>
<!DOCTYPE html>
<html>
    <head>
        <title><%=transition.getString("name")%></title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <script src="<%=contextPath%>/platform/js/eng.js?id=1563926412621" type="text/javascript"></script>
        <link href="<%=contextPath%>/admin/css/sc_admin.css" rel="stylesheet" type="text/css" />
    </head>
    <body>
        <script type="text/javascript">
            eng.initPlatform("/admin/ds/admin.js", true);
        </script>
        <script type="text/javascript">

            var form = eng.createForm({
                width: "100%",
                left: "-8px",
                title: "Información",
                showTabs: false,
                canPrint: false,
                canEdit: <%=eng.hasUserAnyRole(transition.getDataList("roles_view"))%>,
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
            }, <%=sid%>, "<%=transition.getString("ds")%>");

            form.submitButton.setTitle("Guardar");

            form.submitButton.click = function (p1)
            {
                form.setValue("_swbf_processAction",{"itrn":"<%=transition.getNumId()%>","action":"[save]"});
                eng.submit(form, this, function ()
                {
                    isc.say("Datos enviados correctamente...", function () {
                        //parent.loadContent("xx?pid=<%=pid%>&id=" + form.values._id,".content-wrapper");
                    });
                });
            };

            form.buttons.addMember(isc.IButton.create({
                title: "Regresar",
                padding: "10px",
                click: function (p1) {
                    parent.loadContent("admin_content?pid=<%=pid%>",".content-wrapper");
                    return false;
                }
            }));
            form.buttons.members.unshift(form.buttons.members.pop());  
            
<%
    DataObject query=new DataObject();
    query.addSubObject("data").addParam("transition", transition.getId());
    DataObjectIterator it=eng.getDataSource("SWBF_TransitionStates").find(query);
    while (it.hasNext()) {
        DataObject trstate = it.next();
%>
            form.buttons.addMember(isc.IButton.create({
                title: "<%=trstate.getString("title","Enviar")%>",
                padding: "10px",
                click: function (p1) {
                    form.setValue("_swbf_processAction",{"itrn":"<%=transition.getNumId()%>","action":"<%=trstate.getString("action")%>"});
                    eng.submit(form, this, function ()
                    {
                        isc.say("Datos enviados correctamente...", function () {
                            parent.loadContent("admin_content?pid=<%=pid%>",".content-wrapper");
                        });
                    });
                    return false;
                }
            }));    
<%            
    }
%>         
            
            <%=parseScript(transition.getString("formAddiJS"),request,user)%>            
    
        </script>         
    </body>
</html>
<%
    }
%>

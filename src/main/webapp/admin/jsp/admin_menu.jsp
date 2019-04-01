<%-- 
    Document   : menu
    Created on : 19-feb-2018, 15:47:07
    Author     : javiersolis
--%><%@page import="java.util.Iterator"%>
<%@page import="java.io.IOException"%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    DataList getChilds(String parentid, DataList pages)
    {
        DataList ret=new DataList();
        for(int i=0;i<pages.size();i++)
        {
            DataObject obj=pages.getDataObject(i);
            String pid=obj.getString("parentId");
            if(parentid==pid || (parentid!=null && parentid.equals(pid)))
            {
                ret.add(obj);
            }
        }
        return ret;
    }
    
    void writePages(String parentid, DataList pages, JspWriter out, SWBScriptEngine eng) throws IOException
    {
        Iterator<DataObject> it=getChilds(parentid, pages).iterator();
        while (it.hasNext()) {
            DataObject obj = it.next();
            if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))continue;
            String name=obj.getString("name");
            String type=obj.getString("type");
            String path=obj.getString("path");
            String iconClass=obj.getString("iconClass");
            if(iconClass==null)iconClass="fa fa-circle-o";
            if("head".equals(type))
            {
                out.println("<li class=\"header\">"+name+"</li>");
                writePages(obj.getId(), pages, out, eng);
            }else if("group_menu".equals(type))
            {
                out.println("<li class=\"treeview\"><a href=\"#\"><i class=\""+iconClass+"\"></i><span>"+name+"</span><i class=\"fa fa-angle-left pull-right\"></i></a><ul class=\"treeview-menu\">");
                writePages(obj.getId(), pages, out, eng);
                out.println("</ul></li>");
            }else if("url_content".equals(type))
            {
                out.println("<li class=\"\"><a href=\""+path+"\"><i class=\""+iconClass+"\"></i>"+name+"</a></li>");
            }else
            {
                if("sc_grid".equals(type))path="admin_content?pid="+obj.getNumId();
                if("sc_grid_detail".equals(type))path="admin_content?pid="+obj.getNumId();
                if("sc_form".equals(type))path="admin_content?pid="+obj.getNumId();
                if("iframe_content".equals(type))path="admin_content?pid="+obj.getNumId();
                if("ajax_content".equals(type))path="admin_content?pid="+obj.getNumId();
                
                String urlParams=obj.getString("urlParams","");
                if(urlParams.length()>0)
                {
                    urlParams=urlParams.replace("{user.id}",eng.getUser().getId());
                    if(urlParams.startsWith("?") || urlParams.startsWith("&"))urlParams=urlParams.substring(1);
                    path+="&"+urlParams;
                }                
                out.println("<li class=\"treeview\"><a href=\""+path+"\" data-history=\"#"+obj.getNumId()+"\" data-target=\".content-wrapper\" push-menu=true data-load=\"ajax\"><i class=\""+iconClass+"\"></i>"+name+"</a></li>");
            }            
        }
    }
%><%
    SWBScriptEngine engine=DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject query=new DataObject();
    query.addSubList("sortBy").add("order");
    DataList pages=engine.getDataSource("Page").fetch(query).getDataObject("response").getDataList("data");        
%>
<!-- sidebar: style can be found in sidebar.less -->
<section class="sidebar" style_="overflow: scroll">
    <!-- sidebar menu: : style can be found in sidebar.less -->
    <ul class="sidebar-menu tree" data-widget="tree">    
<%
    writePages(null,pages,out,engine);
%>
    </ul>
</section>
<!-- /.sidebar -->
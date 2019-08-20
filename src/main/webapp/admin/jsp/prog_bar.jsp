<%-- 
    Document   : prgmmer
    Created on : 12-feb-2018, 12:10:23
    Author     : javiersolis
--%><%@page import="java.io.IOException"%>
<%@page import="java.util.Iterator"%>
<%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    DataList getChilds(String parentid, DataList pages)
    {
        DataList ret=new DataList();
        for(int i=0;i<pages.size();i++)
        {
            DataObject obj=pages.getDataObject(i);
            String status=obj.getString("status","");
            if(status.equals("disabled"))continue;            
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
                //out.println("<li class=\"header\">"+name+"</li>");
                writePages(obj.getId(), pages, out, eng);
            }else if("group_menu".equals(type))
            {
                out.println("<li class=\"treeview\"><a class=\"cdino_text_menu\" href=\"#\"><i class=\"fa fa-folder-o\"></i><span>"+name+"</span><i class=\"fa fa-angle-left pull-right\"></i></a><ul class=\"treeview-menu\">");
                writePages(obj.getId(), pages, out, eng);
                out.println("</ul></li>");
            }else
            {
                out.println("<li><a class=\"cdino_text_menu\" href=\"uml_funct_model?ID="+obj.getNumId()+"\" data-history=\"#uml_funct_model\" data-target=\".content-wrapper\" data-load=\"ajax\"><i class=\"fa fa-file-o\"></i>"+obj.getString("name")+"</a></li>");
            }           
        }
    }
%>
<section class="sidebar" style_="overflow: scroll">
    <ul class="sidebar-menu tree" data-widget="tree">                             
        <li class="header">Programación</li>
        <li class="treeview">
            <a href="prog_menus" data-history="#prog_menus" data-target=".content-wrapper" data-load="ajax">
                <i class="fa fa-wrench"></i>
                <span>Menus</span>
            </a>
        </li>                        
        <li class="treeview">
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Data Manager</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="prog_ds" data-history="#prog_ds" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataSources</a></li>
                <li><a href="prog_vm" data-history="#prog_vm" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>ValueMaps</a></li>
                <li><a href="prog_valid" data-history="#prog_valid" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Validators</a></li>
                <li><a href="prog_gscript" data-history="#prog_gscript" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>GlobalScripts</a></li>
                <li><a href="prog_jsconsole" data-history="#prog_jsconsole" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>JavaScript Console</a></li>
                <li><a href="prog_dproc" data-history="#prog_dproc" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataProcessors</a></li>
                <li><a href="prog_dsrv" data-history="#prog_dsrv" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataServices</a></li>
                <li><a href="prog_dext" data-history="#prog_dext" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataExtractors</a></li>
            </ul>
            
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Process Manager</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="prog_process" data-history="#prog_process" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Processes</a></li>
            </ul>            
            
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Documentation</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
                        
            <ul class="treeview-menu">
                <!--<li><a href="user_histories" data-history="#user_histories" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>User Histories</a></li>-->
                <li><a href="uml_entity" data-history="#uml" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Entity Diagram</a></li>
                <li class="treeview">
                    <a href="#">
                        <i class="fa fa-wrench"></i>
                        <span>Functional Models</span>
                        <i class="fa fa-angle-left pull-right"></i>
                    </a>
                    <ul class="treeview-menu">
<%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
    
    DataObject query=new DataObject();
    query.addSubList("sortBy").add("order");
    DataList pages=eng.getDataSource("Page").fetch(query).getDataObject("response").getDataList("data");        
    
    writePages(null,pages,out,eng);
    
%>                        
                    </ul>
                </li>     

            </ul>
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Utils</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="prog_impJSON" data-history="#prog_impJSON" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Import JSON Data</a></li>
                <li><a href="prog_export" data-history="#prog_export" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Export Data</a></li>
                <li><a href="JDBCImporter?ajax=true" data-history="#JDBCImporter" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>JDBC Importer</a></li>
            </ul>                                
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Files</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="editor?id=admin&iframe=true" data-history="#editor_admin" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Admin</a></li>
                <li><a href="editor?id=api&iframe=true" data-history="#editor_api" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>API</a></li>
                <li><a href="editor?id=utils&iframe=true" data-history="#editor_utils" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Utils</a></li>
                <li><a href="editor?id=work&iframe=true" data-history="#editor_work" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Work</a></li>
            </ul>
        </li>
    </ul>
</section>

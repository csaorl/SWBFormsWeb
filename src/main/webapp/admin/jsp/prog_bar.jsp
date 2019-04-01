<%-- 
    Document   : prgmmer
    Created on : 12-feb-2018, 12:10:23
    Author     : javiersolis
--%><%@page contentType="text/html" pageEncoding="UTF-8"%>
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
                <span>DataManager</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
            <ul class="treeview-menu">
                <li><a href="prog_ds" data-history="#prog_ds" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataSources</a></li>
                <li><a href="prog_vm" data-history="#prog_vm" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>ValueMaps</a></li>
                <li><a href="prog_valid" data-history="#prog_valid" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>Validators</a></li>
                <li><a href="prog_dproc" data-history="#prog_dproc" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataProcessors</a></li>
                <li><a href="prog_dsrv" data-history="#prog_dsrv" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>DataServices</a></li>
            </ul>
            
            <a href="#">
                <i class="fa fa-wrench"></i>
                <span>Documentation</span>
                <i class="fa fa-angle-left pull-right"></i>
            </a>
                        
            <ul class="treeview-menu">
                <li><a href="user_histories" data-history="#user_histories" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>User Histories</a></li>
                <li><a href="uml" data-history="#uml" data-target=".content-wrapper" data-load="ajax"><i class="fa fa-gear"></i>UML Class</a></li>
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

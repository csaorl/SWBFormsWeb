<%-- 
    Document   : uml
    Created on : 17-mar-2018, 17:45:33
    Author     : javiersolis
--%>
<%@page import="javax.script.ScriptException"%>
<%@page import="java.io.IOException"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.util.HashMap"%>
<%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    public StringBuilder getFields(DataObject obj, String propsField, SWBScriptEngine eng)throws IOException
    {
        SWBDataSource ds=eng.getDataSource("DataSource");
        DataObject query=new DataObject();
        query.addSubObject("data").addParam("ds", ds.getBaseUri()+obj.getString("ds"));
        DataObject map=eng.getDataSource("DataSourceFields").mapByField(query,"name");

        StringBuilder fields=new StringBuilder();
        DataList gridProps=obj.getDataList(propsField);
        if(gridProps!=null)
        {
            Iterator<String> it=gridProps.iterator();
            while (it.hasNext()) {
                String _id = it.next();
                String name=_id.substring(_id.indexOf(".")+1);
                //String name=eng.getDataSource("DataSourceFields").getObjectById(_id,DataObject.EMPTY).getString("title",_id);
                fields.append(map.getDataObject(name,DataObject.EMPTY).getString("title","-"));
                if(it.hasNext())fields.append(";");
            }
        }else
        {
            Iterator it=map.values().iterator();
            while (it.hasNext()) {
                DataObject prop = (DataObject)it.next();
                fields.append(prop.getString("title","-"));
                if(it.hasNext())fields.append(";");
            }
        }
        return fields;
    }


/*   
    [<actor>Programador|Acceso;Creación;Edición]
    [<actor>Administrador|Acceso;Creación;Edición]
    [<actor>Super User|Acceso;Creación;Edición;Eliminación]
    [<frame>Usuarios|Tipo:Grid-Detail|[Lista (Grid)|Correo;Password;Nombre Completo; Roles]-->[Forma (Detalle)|Correo;Password;Nombre Completo;
    Roles;Fecha de creación;Usuario Creador;Fecha de Modificación; Usuario Modificador]]
    [<database> User]        
    [Usuarios]--[User]
    [Programador] -- [Usuarios]
    [Administrador] -- [Usuarios]
    [Super User] -- [Usuarios]        
*/       
    public String getDiagram(DataObject obj, SWBScriptEngine eng) throws ScriptException, IOException
    {
        StringBuilder data=new StringBuilder();

        DataObject roles=(DataObject)DataUtils.toData(eng.eval("roles"));
        DataObject types=(DataObject)DataUtils.toData(eng.eval("type_pages"));   
        
        DataList emptyList=new DataList();
        DataList roles_view=obj.getDataList("roles_view",emptyList);
        DataList roles_add=obj.getDataList("roles_add",emptyList);
        DataList roles_update=obj.getDataList("roles_update",emptyList);
        DataList roles_remove=obj.getDataList("roles_remove",emptyList);  

        DataObject rolesMap=new DataObject();
                
        Iterator<String> it=roles_view.iterator();
        while (it.hasNext()) {
            String key = it.next();
            rolesMap.put(key, roles.getString(key));
        }
        it=roles_add.iterator();
        while (it.hasNext()) {
            String key = it.next();
            rolesMap.put(key, roles.getString(key));
        }
        it=roles_update.iterator();
        while (it.hasNext()) {
            String key = it.next();
            rolesMap.put(key, roles.getString(key));
        }
        roles_remove.iterator();
        while (it.hasNext()) {
            String key = it.next();
            rolesMap.put(key, roles.getString(key));
        }
        
        for(String role:rolesMap.keySet())
        {
            data.append("[");
            data.append("<actor>");
            data.append(rolesMap.getString(role,role));
            data.append("|");
            StringBuilder ret=new StringBuilder();
            if(roles_view.contains(role))ret.append("Acceso;");
            if(roles_add.contains(role))ret.append("Creación;");
            if(roles_update.contains(role))ret.append("Edición;");
            if(roles_remove.contains(role))ret.append("Eliminación;");
            if(ret.length()>0)ret.deleteCharAt(ret.length()-1);
            data.append(ret);
            data.append("]\\n");
        }
        
        data.append("[");
        data.append("<frame>");
        data.append(obj.getString("name"));
        data.append("|");
        data.append("Tipo: ");
        
        String type=obj.getString("type");        
        data.append(types.get(type));
        if(type.startsWith("sc_grid"))
        {
            data.append("|[Lista (Grid)|");            
            data.append(getFields(obj, "gridProps", eng));
            
            if(type.equals("sc_grid_detail"))
            {                
                data.append("]-->");    
            }else
            {
                data.append("]\\n");    
            }
        }
        if(type.equals("sc_grid_detail") || type.equals("sc_form"))
        {
            if(type.equals("sc_form"))data.append("|");      
            data.append("[Forma (Detalle)|");            
            data.append(getFields(obj, "formProps", eng));
            data.append("]\\n");    
        }        
        if(type.equals("url_content") || type.equals("ajax_content") || type.equals("iframe_content"))
        {
            data.append("|path: ");            
            data.append(obj.getString("path"));
            data.append("");    
        }   
        if(type.startsWith("process_tray"))
        {
            data.append("|[Processos (Bandeja)|");            
            data.append(getFields(obj, "gridProps", eng));
            data.append("]-->");    
            data.append("[Proceso (Detalle)|");            
            data.append(getFields(obj, "formProps", eng));
            data.append("]\\n");    
        }  

        //findChilds
        DataObject query=new DataObject();
        query.addSubList("sortBy").add("order");
        query.addSubObject("data").addParam("parentId", obj.getId());
        DataList childs=eng.getDataSource("Page").fetch(query).getDataObject("response").getDataList("data"); 
        Iterator<DataObject> it2=childs.iterator();
        while (it2.hasNext()) {
            DataObject tab = it2.next();    
            String sub=getDiagram(tab, eng);
            if(sub.length()>0)
            {
                data.append("|tab: "+tab.getString("name")+"|");            
                data.append(sub);
            }
        }

        data.append("]\\n");
        
        String ds=obj.getString("ds");
        if(ds!=null)
        {
            ds="DS:"+ds;
            data.append("[");
            data.append("<database>");
            data.append(ds);
            data.append("]\\n");            
            
            data.append("[");
            data.append(obj.getString("name"));
            data.append("]--");
            data.append("[");
            data.append(ds);
            data.append("]\\n");            
        }
        
        for(String role:rolesMap.keySet())
        {
            data.append("[");
            data.append(rolesMap.getString(role,role));
            data.append("]--");
            data.append("[");
            data.append(obj.getString("name"));
            data.append("]\\n");            
        }

        return data.toString();
    }

%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);    
    boolean iframe=request.getParameter("iframe")!=null;     
    String ID=request.getParameter("ID");     
    //System.out.println(obj);
    String _title="Functional Model Diagram";
    String _fileName=contextPath+"/admin/jsp/uml_funct_model.jsp";
    //if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))response.sendError(403,"Acceso Restringido...");
    
    
    DataObject obj=eng.getDataSource("Page").fetchObjByNumId(ID);        
    String _smallName=obj.getString("name");
    
    String data="";
    
    if(iframe)
    {        
        data=getDiagram(obj,eng);
    }
            
    //********************************** Ajax Content ************************************************************
    if(!iframe)
    {
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small><%=_smallName%></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programación</li>
        <li class="active"><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
    </ol>
</section>
<!-- Main content -->
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&ID=<%=ID%>" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>            
</section>
<!-- /.content -->
<%
        //********************************** End Ajax ************************************************************
    }else
    {
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>UML</title>
        <style>
            body{
                background-color: white;
            }
        </style>
    </head>
    <body>
        <script src="<%=contextPath%>/admin/utils/nomnoml/lodash.min.js"></script>
        <script src="<%=contextPath%>/admin/utils/nomnoml/dagre.min.js"></script>
        <script src="<%=contextPath%>/admin/utils/nomnoml/nomnoml.js"></script>

        <canvas id="target-canvas" style="height: 100%"></canvas>
        <script>
            var canvas = document.getElementById('target-canvas');
            var data="<%=data%>";
            nomnoml.draw(canvas, data);
        </script>   
    </body>
</html>
<%
    }
%>
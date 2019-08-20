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
                fields.append(map.getDataObject(name).getString("title","-"));
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

    String getTransitionName(DataObject trans, DataObject roles, boolean addRoles)
    {
        String ret=trans.getString("name");
        if(addRoles)
        {
            DataList<String> roles_view=trans.getDataList("roles_view");
            if(roles_view!=null)
            {
                ret+=" (";
                boolean first=true;
                for(String role:roles_view)
                {
                    ret+=roles.getString(role);
                    if(!first)ret+=", ";
                    first=false;                
                }
                ret+=")";
            }
        }
        return ret;
    }
    
/*   
#.state: visual=ellipse fill=#60a0a0 stroke=#ffffff
#.trans: visual=transceiver
#.auto: visual=sender stroke=#909090

[<hidden>_start_]
[<trans> Empleado]
[<trans> Jefe]
[<trans> RecHum]
[<auto> Rechazado]
[<auto> Aprobado]
[<state> EMPLEADO]
[<state> JEFE]
[<state> RH]
[<state> RECHAZADO]
[<state> ACEPTADO]


[_start_]--:>[Empleado]
[Empleado]->send[JEFE]
[JEFE]->[Jefe]
[Jefe]->si[RH]
[RH]->[RecHum]
[RecHum]->si[ACEPTADO]
[RecHum]->no[RECHAZADO]
[Jefe]->no[RECHAZADO]
[RECHAZADO]->[Rechazado]
[ACEPTADO]->[Aprobado]
[Jefe]->back[EMPLEADO]
[EMPLEADO]->[Empleado]   
*/       
    public String getDiagram(DataObject obj, DataObject res, SWBScriptEngine eng, boolean doc) throws ScriptException, IOException
    {
        StringBuilder data=new StringBuilder();

        data.append("#.astate: visual=ellipse fill=#ffff10 stroke=#606060"+"\\n");
        data.append("#.state: visual=ellipse fill=#60a0a0 stroke=#ffffff"+"\\n");
        data.append("#.trans: visual=transceiver"+"\\n");
        data.append("#.auto: visual=sender stroke=#909090"+"\\n");
        data.append("\\n");
        data.append("[<hidden>_start_]"+"\\n");

        //System.out.println("Step 0");

        DataObject roles=(DataObject)DataUtils.toData(eng.eval("roles"));
        DataObject stypes=(DataObject)DataUtils.toData(eng.eval("stype_transitions"));   
        DataObject ptypes=(DataObject)DataUtils.toData(eng.eval("ptype_transitions"));  

        //System.out.println("Step 1");
        
        DataObject query=new DataObject();
        query.addSubObject("data").addParam("process", obj.getId());
        DataObject states=eng.getDataSource("SWBF_State").mapById(query);
        Iterator it=states.values().iterator();
        while (it.hasNext()) {
            DataObject sobj = (DataObject)it.next();
            String prop=sobj.getString("prop");
            boolean active=false;
            if(res!=null && prop!=null)
            {
                prop=prop.substring(prop.indexOf(".")+1);
                if(sobj.getString("value").equals(res.getString(prop)))
                {
                    active=true;
                }
            }
            if(active)data.append("[<astate> ");
            else data.append("[<state> ");
            data.append(sobj.getString("name")+"]\\n");
        }

        //System.out.println("Step 2");

        query=new DataObject();
        query.addSubObject("data").addParam("process", obj.getId());
        DataObject transitions=eng.getDataSource("SWBF_Transition").mapById(query);
        it=transitions.values().iterator();
        while (it.hasNext()) 
        {
            DataObject trans = (DataObject)it.next();

            data.append("[<frame> "+getTransitionName(trans,roles,!doc));

            //System.out.println("Step 2.1");

            if(doc)
            {
                DataList<String> roles_view=trans.getDataList("roles_view");
                if(roles_view!=null)
                {
                    data.append("|Roles: ");
                    for(String role:roles_view)
                    {
                        data.append(roles.getString(role)+" ");
                    }
                }

                String type=trans.getString("type");
                if(type!=null)
                {
                    data.append("|Tipo: ");
                    data.append(stypes.getString(type)+"\\n");
                }

                //System.out.println("Step 2.2");

                String ptype=trans.getString("ptype","");        
                if(ptype.startsWith("sc_grid"))
                {
                    data.append("|[Lista|");            
                    data.append(getFields(trans, "gridProps", eng));
                    if(ptype.equals("sc_grid_detail"))
                    {                
                        data.append("]-->");    
                    }else
                    {
                        data.append("]\\n");    
                    }
                }            

                //System.out.println("Step 2.3");

                if(ptype.equals("sc_grid_detail") || ptype.equals("sc_form"))
                {
                    if(ptype.equals("sc_form"))data.append("|");      
                    data.append("[Forma|");            
                    data.append(getFields(trans, "formProps", eng));
                    data.append("]\\n");    
                }        
                if(ptype.equals("url_content") || ptype.equals("ajax_content") || ptype.equals("iframe_content"))
                {
                    data.append("|path: ");            
                    data.append(trans.getString("path"));
                    data.append("");    
                } 
            }

            data.append("]"+"\\n");

        }

        //System.out.println("Step 3");


        DataObject ini=transitions.getDataObject(obj.getString("initTransition"));
        if(ini!=null)
        {
            data.append("[_start_]--:>["+getTransitionName(ini,roles,!doc)+"]"+"\\n");
        }

        //System.out.println("Step 4");

        it=transitions.values().iterator();
        while (it.hasNext()) {
            DataObject trans = (DataObject)it.next();
            
            DataList<String> sources=trans.getDataList("sourceStates");
            if(sources!=null)
            {
                for(String stateid:sources)
                {
                    DataObject orig=states.getDataObject(stateid);
                    if(orig!=null)
                    {
                        data.append("["+orig.getString("name")+"]"+"->");
                        data.append("["+getTransitionName(trans,roles,!doc)+"]"+"\\n");
                    }
                }
            }

            query=new DataObject();
            query.addSubObject("data").addParam("transition", trans.getId());
            DataObjectIterator it2=eng.getDataSource("SWBF_TransitionStates").find(query);
            while (it2.hasNext()) {
                DataObject transtate = it2.next();
                DataList sts=transtate.getDataList("states");
                if(sts!=null)
                {
                    for(int x=0;x<sts.size();x++)
                    {
                        DataObject dest=states.getDataObject((String)sts.get(x));
                        if(dest!=null)
                        {
                            data.append("["+getTransitionName(trans,roles,!doc)+"]"+"->"+transtate.getString("title","")+"["+dest.getString("name")+"]"+"\\n");
                        }
                    }
                }
            }

        }

        //System.out.println("Step 5");

        return data.toString();
    }

%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);    
    boolean iframe=request.getParameter("iframe")!=null;     
    String id=request.getParameter("id");     
    String resid=request.getParameter("resid");    
    Boolean doc=request.getParameter("doc")!=null;        
    
    //System.out.println(obj);
    String _title="Process Diagram";
    String _fileName=contextPath+"/admin/jsp/uml_process.jsp";
    //if(!eng.hasUserAnyRole(obj.getDataList("roles_view")))response.sendError(403,"Acceso Restringido...");
    
    
    DataObject obj=eng.getDataSource("SWBF_Process").fetchObjById(id);  
    DataObject res=null;
    if(resid!=null)
    {
        res=eng.getDataSource(obj.getString("ds")).fetchObjById(resid); 
    }    
    
    String _smallName=obj.getString("name");
    
    String data="";
    
    if(iframe)
    {        
        data=getDiagram(obj,res, eng, doc);
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
    <iframe class="ifram_content" src="<%=_fileName%>?iframe=true&id=<%=id%>" frameborder="0" width="100%"></iframe>
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
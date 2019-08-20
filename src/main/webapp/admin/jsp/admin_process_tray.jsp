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


    DataObject getProps(SWBScriptEngine eng, String dataSource, DataList props, DataList extProps)
    {
        SWBDataSource ds=eng.getDataSource(dataSource);
        DataObject script=ds.getDataSourceScript().toDataObject();
        DataList<DataObject> dsFields=script.getDataList("fields");
        DataObject ret=new DataObject();

        DataList empty=new DataList();
        
        if(props!=null)
        {
            for(Object prop: props)
            {
                String name=((String)prop).substring(((String)prop).indexOf(".")+1);
                DataObject act=dsFields.findDataObject("name", name);                
                if(act!=null)ret.addParam(name,act);

                for(int i=0;i<extProps.size();i++)
                {
                    DataObject ext=extProps.getDataObject(i);
                    if(ext.getDataList("prop",empty).contains((String)prop))
                    {
                        String att=ext.getString("att");
                        if(att.equals("canEditRoles")) {
                            boolean enabled = eng.hasUserAnyRole(ext.getString("value").split(","));
                            act.addParam("disabled",!enabled);
                        }else if(att.equals("canViewRoles")) {
                            boolean visible = eng.hasUserAnyRole(ext.getString("value").split(","));
                            act.addParam("visible",visible);
                        }else {
                            // original
                            String value=ext.getString("value");
                            String type=ext.getString("type");
                            act.addParam(att, parseFieldValue(value, type));
                        }
                    }
                }

            }
        }
        return ret;   
    }

    Object parseFieldValue(String value, String type)
    {
        //["boolean","date","double","float","int","long","password","select","string","object","time"]
        if(type==null)return value;
        if(type.equals("boolean"))return Boolean.parseBoolean(value);
        if(type.equals("float"))return Float.parseFloat(value);
        if(type.equals("double"))return Double.parseDouble(value);
        if(type.equals("int"))return Integer.parseInt(value);
        if(type.equals("long"))return Long.parseLong(value);
        if(type.equals("object"))return DataObject.parseJSON(value);        
        return value;
    }

    String getValue(DataObject rec, DataObject prop, SWBScriptEngine eng) throws IOException
    {
        String value=rec.getString(prop.getString("name"));
        if("select".equals(prop.getString("stype")))
        {
            SWBDataSource ds=eng.getDataSource(prop.getString("dataSource"));
            String displayField=ds.getDataSourceScript().getString("displayField");
            String valueField=prop.getString("valueField");

            System.out.println("value:"+value);
            System.out.println("ds:"+ds);            
            System.out.println("displayField:"+displayField);

            if(displayField!=null && (valueField==null || (valueField!=null && !valueField.equals(displayField))))
            {
                DataObject cache=prop.getDataObject("_cache_");
                if(cache==null)
                {
                    cache=ds.mapByField(valueField!=null?valueField:"_id");
                    prop.addParam("_cache_", cache);
                }
                DataObject ref=cache.getDataObject(value,DataObject.EMPTY);
                value=ref.getString(displayField);
            }
            System.out.println("value2:"+value);
        }
        if(value==null)value="_";
        return value;
    }

    
%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user=eng.getUser();
    System.out.println("user:"+user);
    
    String pid=request.getParameter("pid");
    DataObject opage=eng.getDataSource("Page").getObjectByNumId(pid);   
    
    SWBProcess process=eng.getProcessMgr().getProcess(opage.getString("process"));
    System.out.println("process:"+process);
    String ds=opage.getString("ds"); 
    System.out.println("ds:"+ds);
    DataObject initTransition=process.getUserInitTransition(eng);
    
%>
<style>
    #processTable thead {
        background-color: rgb(71, 167, 227);
        color: white;
    }
    
    .processButtons {
        text-align: right;
        padding: 10px;
        border-top: 1px solid #3c8dbc;
    }
    
    tr:hover {
        background-color: rgb(182, 227, 255, 0.79) !important;
    }
</style>

<div class="modal modal-info fade" id="modal-info">
  <div class="modal-dialog">
    <div class="modal-content" id="modal-content">
    </div>
    <!-- /.modal-content -->
  </div>
  <!-- /.modal-dialog -->
</div>
<div class="row">
    <div class="col-md-12" id="main_content">    
        <div class="row" style="margin:2px;">            
            <div style="background-color: white;">
                
                <!-- /.box-header -->
                <div class="box-body" style_="overflow: scroll;">
                    <table id="processTable" class="table table-bordered table-striped">
                        <thead>
                            <tr>
<%
    DataList extProps=getExtProps(opage,"gridExtProps",eng);
    DataObject fields=getProps(eng,ds,opage.getDataList("gridProps"), extProps);
    Iterator it=fields.values().iterator();
    while (it.hasNext()) {
        DataObject prop=(DataObject)it.next();
        String width=prop.getString("width");
        if(!prop.getBoolean("visible",true))continue;
%>                                
                                <th<%=(width!=null)?" width=\""+width+"\"":""%>><%=prop.getString("title")%></th>
<%
    }
%>                                
                                <th style="width: 120px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>            
<%
    DataList<String> accessProps=new DataList();
    Iterator it3=process.getTransitions().values().iterator();
    while (it3.hasNext()) 
    {
        DataObject trans = (DataObject)it3.next();
        String prop=trans.getString("asigProp");
        if(prop!=null && eng.hasUserAnyRole(trans.getDataList("roles_view")))
        {
            prop=prop.substring(prop.indexOf(".")+1);   
            accessProps.add(prop);
        }
    }
    
    DataObject query=new DataObject();    
    DataList or=query.addSubObject("data").addSubList("$or");
    
    //{$or: [ {"jefe":{ $exists: false}}, {"jefe": "_suri:SWBForms:User:5d3b3caecb2eb86473978bd8" }]}    
    for(String prop: accessProps)
    {
        DataObject ex=new DataObject();
        ex.addSubObject(prop).addParam("$exists", false);
        or.add(ex);
        or.add(new DataObject().addParam(prop, user.getId()));
    }
    if(or.isEmpty())query.getDataObject("data").remove("$or");

    //System.out.println("query:"+query);
    
    DataObjectIterator it2=eng.getDataSource(ds).find(query);
    while (it2.hasNext()) {
        DataObject rec = it2.next();
        DataList trans=process.getNextTransitions(eng, rec);


%>
                            <tr style="cursor: pointer;" onclick="loadContent('admin_process_view?pid=<%=pid%>&id=<%=rec.getId()%>', '.content-wrapper',null,null,'#admin_process_view/<%=pid%>/<%=rec.getNumId()%>');return false;">
<%        
    
        it=fields.values().iterator();
        while (it.hasNext()) {
            DataObject prop=(DataObject)it.next();
            if(!prop.getBoolean("visible",true))continue;
%>                                
                                <td><%=getValue(rec,prop, eng)%></td>
<%
        }
%>
                                <td style="text-align: center">
<%
        for(Object tran:trans)
        {
%>
                                    <button type="button" style="" class="btn bg-green btn-flat" onclick="loadContent('admin_process?itrn=<%=((DataObject)tran).getNumId()%>&pid=<%=pid%>&id=<%=rec.getId()%>', '.content-wrapper',null,null,'#admin_process/<%=pid%>');return false;"><%=((DataObject)tran).getString("name")%></button>
<%
        }
%>
                                </td>
                            </tr>
<%
    }
%>                                
                        </tbody>
                    </table>
                </div>
                
                <div class="processButtons">
<%
    if(initTransition!=null)
    {
%>                    
                    <a href="admin_process?itrn=<%=initTransition.getNumId()%>&pid=<%=pid%>" data-target=".content-wrapper" data-load="ajax" class="btn btn-primary">Iniciar <%=process.getDataObject().getString("name")%></a>
<%
    }
%>                    
                </div>    
                
                <!-- /.box-body -->
            </div>
            <!-- /.box -->          
            
        </div> 
    </div><!-- /.col -->
</div>


<script type="text/javascript">
    $('button').click(function(e) {
        e.stopPropagation();
        if(e.cancelBubble)
        {
            e.cancelBubble();
        }
    });
    
    $('.box').boxWidget({
        animationSpeed: 500,
    });
    
    $(function () {
      $('#processTable').DataTable({
        'paging'      : true,
        'lengthChange': false,
        'searching'   : true,
        'ordering'    : true,
        'info'        : true,
        'autoWidth'   : true,
        'language': {'url': '//cdn.datatables.net/plug-ins/1.10.16/i18n/Spanish.json'}
      });
    })

</script>


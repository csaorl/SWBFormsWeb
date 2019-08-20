<%-- 
    Document   : ImportJDBC
    Created on : 13-ago-2019, 16:06:59
    Author     : javiersolis
--%>
<%@page import="java.io.IOException"%>
<%@page import="org.postgresql.core.BaseConnection"%>
<%@page import="org.semanticwb.datamanager.*"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%><%!
    
    static DataObject TYPE_MAP=null;

    static{
        TYPE_MAP=new DataObject();
        TYPE_MAP.addParam("-7", "boolean");  //BIT
        TYPE_MAP.addParam("-6", "int");      //TINYINT
        TYPE_MAP.addParam("-5", "long");     //BIGINT
        TYPE_MAP.addParam("-4", "object");   //-4	LONGVARBINARY 
        TYPE_MAP.addParam("-3", "object");     //-3	VARBINARY
        TYPE_MAP.addParam("-2", "object");     //-2	BINARY
        TYPE_MAP.addParam("-1", "text");     //-1	LONGVARCHAR
        TYPE_MAP.addParam("0", "string");     //0	NULL
        TYPE_MAP.addParam("1", "string");     //1	CHAR
        TYPE_MAP.addParam("2", "double");     //2	NUMERIC
        TYPE_MAP.addParam("3", "double");     //3	DECIMAL
        TYPE_MAP.addParam("4", "int");       //4	INTEGER
        TYPE_MAP.addParam("5", "int");       //5	SMALLINT
        TYPE_MAP.addParam("6", "float");     //6	FLOAT
        TYPE_MAP.addParam("7", "double");    //7	REAL
        TYPE_MAP.addParam("8", "double");    //8	DOUBLE
        TYPE_MAP.addParam("12", "string");   //12	VARCHAR
        TYPE_MAP.addParam("91", "date");     //91	DATE
        TYPE_MAP.addParam("92", "time");     //92	TIME
        TYPE_MAP.addParam("93", "date");     //93	TIMESTAMP
        TYPE_MAP.addParam("1111", "string"); //1111 	OTHER
    }

    public String formatTitle(String title)
    {
        String ret="";
        String titles[]=title.split("_");
        for(String t:titles)
        {
            if(ret.length()>0)ret+=" ";
            ret+=t.substring(0,1).toUpperCase()+t.substring(1);
        }
        return ret;
    }
    
    public boolean createDataSource(String schema, String table, JspWriter out, Connection conn, SWBScriptEngine eng, DataList tablesCreated) throws SQLException, IOException
    {
        SWBDataSource ds_ds=eng.getDataSource("DataSource");
        SWBDataSource dsf_ds=eng.getDataSource("DataSourceFields");
        SWBDataSource dsfe_ds=eng.getDataSource("DataSourceFieldsExt");

        DataObject dataSources=ds_ds.mapByField("id");

        if(dataSources.containsKey(table))return false;
        
        //Obtener Descripcion de la tabla
        String description=null;
        DatabaseMetaData md = conn.getMetaData();
        ResultSet rsTable = md.getTables(null, schema, table, null);
        while(rsTable.next()) {
          String type=rsTable.getString(4);
          String comments=rsTable.getString(5);
          if("TABLE".equals(type))
          {
              description=comments;
              break;
          }
        }
        rsTable.close();

        //Creamos DataSource
        DataObject ds_obj=new DataObject();
        ds_obj.addParam("id", table);
        ds_obj.addParam("scls", table);
        ds_obj.addParam("backend", true);
        ds_obj.addParam("frontend", true);
        if(description!=null)ds_obj.addParam("description", description);

        //GetPrimarykeys
        ResultSet PK = md.getPrimaryKeys(null,schema, table);
        if(PK.next())
        {
            String pk=PK.getString("COLUMN_NAME");            
            ds_obj.addParam("displayField", pk);
        }
        PK.close();

        DataObject retds=ds_ds.addObj(ds_obj).getDataObject("response").getDataObject("data");
        out.println("DataSource created:"+retds);
        tablesCreated.add(schema+"."+table);

        String dsId=retds.getId();
                
        //GET Colums
        String auntoInc=null;
        DataObject fields=new DataObject();
        ResultSet columns = md.getColumns(null,schema, table, null);
        while(columns.next())
        {
            //ResultSetMetaData rsmd=columns.getMetaData();
            String columnName = columns.getString("COLUMN_NAME");

            if(columnName.equals("descripcion"))ds_ds.updateObj(retds.addParam("displayField", "descripcion"));       //TODO:Configurable            

            boolean isTimestamp="93".equals(columns.getString("DATA_TYPE"));
            String datatype = TYPE_MAP.getString(columns.getString("DATA_TYPE"),"string");
            String typename = columns.getString("TYPE_NAME");
            String columnsize = columns.getString("COLUMN_SIZE");
            String decimaldigits = columns.getString("DECIMAL_DIGITS");
            boolean isNullable = columns.getBoolean("IS_NULLABLE");
            boolean is_autoIncrement = columns.getBoolean("IS_AUTOINCREMENT");
            String is_generatedcolumn = columns.getString("IS_GENERATEDCOLUMN");
            String comments = columns.getString("REMARKS");
            //Printing results
            if(is_autoIncrement)auntoInc=columnName;

            DataObject dsf_obj=new DataObject();
            dsf_obj.addParam("ds", dsId);
            dsf_obj.addParam("name", columnName);
            dsf_obj.addParam("title", formatTitle(columnName));
            dsf_obj.addParam("type", datatype);
            if(columnsize!=null)dsf_obj.addParam("length", Integer.parseInt(columnsize));
            dsf_obj.addParam("required", (!datatype.equals("boolean")?!isNullable:false));
            if(comments!=null)dsf_obj.addParam("description", comments);
            DataObject ret=dsf_ds.addObj(dsf_obj).getDataObject("response").getDataObject("data");
            fields.addParam(columnName, ret.getId());

            if(isTimestamp)
            {
                DataObject dsfe_obj=new DataObject();
                dsfe_obj.addParam("dsfield", ret.getId());
                dsfe_obj.addParam("type", "string");
                dsfe_obj.addParam("att", "editorType");
                dsfe_obj.addParam("value", "DateTimeItem");
                dsfe_ds.addObj(dsfe_obj);

                dsfe_obj=new DataObject();
                dsfe_obj.addParam("dsfield", ret.getId());
                dsfe_obj.addParam("type", "boolean");
                dsfe_obj.addParam("att", "useTextField");
                dsfe_obj.addParam("value", true);
                dsfe_ds.addObj(dsfe_obj);

                dsfe_obj=new DataObject();
                dsfe_obj.addParam("dsfield", ret.getId());
                dsfe_obj.addParam("type", "boolean");
                dsfe_obj.addParam("att", "useMask");
                dsfe_obj.addParam("value", true);
                dsfe_ds.addObj(dsfe_obj);
            }

            out.println("DataSourceField created:"+columnName);
        }
        columns.close();
        out.println();

        //GetPrimarykeys
        PK = md.getPrimaryKeys(null,schema, table);
        System.out.println("------------PRIMARY KEYS-------------");
        while(PK.next())
        {
            String columName=PK.getString("COLUMN_NAME");

            DataObject dsfe_obj=new DataObject();
            dsfe_obj.addParam("dsfield", fields.getString(columName));
            dsfe_obj.addParam("type", "string");
            dsfe_obj.addParam("att", "stype");
            dsfe_obj.addParam("value", "id");
            DataObject ret=dsfe_ds.addObj(dsfe_obj).getDataObject("response").getDataObject("data");
            //out.println("DataSourceFieldExt created:"+ret);

            dsfe_obj=new DataObject();
            dsfe_obj.addParam("dsfield", fields.getString(columName));
            dsfe_obj.addParam("type", "object");
            dsfe_obj.addParam("att", "validators");
            dsfe_obj.addParam("value", DataObject.parseJSON("[\"unique\"]"));
            ret=dsfe_ds.addObj(dsfe_obj).getDataObject("response").getDataObject("data");
            //out.println("DataSourceFieldExt created:"+ret);
            //out.println(PK.getString("COLUMN_NAME") + "===" + PK.getString("PK_NAME"));
        }
        PK.close();
        out.println();

        //Get Foreign Keys
        ResultSet FK = md.getImportedKeys(null, schema, table);
        System.out.println("------------FOREIGN KEYS-------------");
        while(FK.next())
        {
            if(!dataSources.containsKey(FK.getString("PKTABLE_NAME")))createDataSource(schema, FK.getString("PKTABLE_NAME"), out, conn, eng, tablesCreated);

            DataObject dsfe_obj=new DataObject();
            dsfe_obj.addParam("dsfield", fields.getString(FK.getString("FKCOLUMN_NAME")));
            dsfe_obj.addParam("type", "string");
            dsfe_obj.addParam("att", "stype");
            dsfe_obj.addParam("value", "select");
            DataObject ret=dsfe_ds.addObj(dsfe_obj).getDataObject("response").getDataObject("data");
            //out.println("DataSourceFieldExt created:"+ret);

            dsfe_obj.addParam("dsfield", fields.getString(FK.getString("FKCOLUMN_NAME")));
            dsfe_obj.addParam("type", "string");
            dsfe_obj.addParam("att", "dataSource");
            dsfe_obj.addParam("value", FK.getString("PKTABLE_NAME"));
            ret=dsfe_ds.addObj(dsfe_obj).getDataObject("response").getDataObject("data");
            //out.println("DataSourceFieldExt created:"+ret);
            out.println("Relation created:"+FK.getString("PKTABLE_NAME"));

            dsfe_obj.addParam("dsfield", fields.getString(FK.getString("FKCOLUMN_NAME")));
            dsfe_obj.addParam("type", "string");
            dsfe_obj.addParam("att", "valueField");
            dsfe_obj.addParam("value", FK.getString("PKCOLUMN_NAME"));
            ret=dsfe_ds.addObj(dsfe_obj).getDataObject("response").getDataObject("data");
            //out.println("DataSourceFieldExt created:"+ret);
            
            //out.println(FK.getString("FKTABLE_NAME") + "." + FK.getString("FKCOLUMN_NAME")+ " --> " + FK.getString("PKTABLE_NAME") + "." + FK.getString("PKCOLUMN_NAME") );
        }
        FK.close();
        out.println();

        //Get Indexes
        ResultSet indexValues = md.getIndexInfo(null, schema, table, true, false);
        while (indexValues.next()) 
        {
            String INDEX_NAME = indexValues.getString("INDEX_NAME");
            boolean NON_UNIQUE = indexValues.getBoolean("NON_UNIQUE");
            int TYPE = indexValues.getInt("TYPE");
            String COLUMN_NAME = indexValues.getString("COLUMN_NAME");
            String ASC_OR_DESC = indexValues.getString("ASC_OR_DESC");
            long CARDINALITY = indexValues.getLong("CARDINALITY");
            String FILTER_CONDITION = indexValues.getString("FILTER_CONDITION");

            //out.println("Index:"+INDEX_NAME+"--"+NON_UNIQUE+"--"+TYPE+"--"+COLUMN_NAME+"--"+ASC_OR_DESC+"--"+CARDINALITY+"--"+FILTER_CONDITION);
        }
        out.println();

        return true;
    }

    public boolean importData(String squema, String table, JspWriter out, Connection conn, SWBScriptEngine eng) throws SQLException, IOException
    {
        SWBDataSource ds=eng.getDataSource(table);
        //GetData
        Statement stmt = conn.createStatement();
        String sql= "SELECT * FROM "+table;

        ResultSet rs = stmt.executeQuery(sql);
        ResultSetMetaData rsmd=rs.getMetaData();
        int l=rsmd.getColumnCount();
        while(rs.next()){
            DataObject rec=new DataObject();
            for(int x=1;x<l;x++)
            {
                Object value=rs.getObject(x);
                if(value!=null)rec.addParam(rsmd.getColumnName(x), value);
            }
            //System.out.println(rec);
            DataObject ret=ds.addObj(rec).getDataObject("response").getDataObject("data");
            //System.out.println("Insert Data:"+ret.getNumId());
        }   
        rs.close();
        return true;
    }

    public boolean createMenu(String squema, String table, JspWriter out, Connection conn, SWBScriptEngine eng) throws SQLException, IOException
    {
        SWBDataSource ds=eng.getDataSource("Page");
        DataObject page=new DataObject();
        page.addParam("id", table);
        page.addParam("name", formatTitle(table));
        page.addParam("parentId", ds.getBaseUri()+"catalogs");
        int props=eng.getDataSource(table).getDataSourceScript().get("fields").size();
        if(props>7)
        {
            page.addParam("type", "sc_grid_detail");
        }else
        {
            page.addParam("type", "sc_grid");
        }
        page.addSubList("roles_view").add("admin");
        page.addParam("status", "active");
        page.addParam("ds", table);
        page.addSubList("roles_add").add("admin");
        page.addSubList("roles_update").add("admin");
        page.addSubList("roles_remove").add("admin");
        page.addSubList("icon").add("sc_grid.png");

        DataObject ret=ds.addObj(page).getDataObject("response").getDataObject("data");
        out.println("Insert Menu:"+table);

        return true;
    }

%><%
    String contextPath = request.getContextPath();     
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/admin.js", session);
    DataObject user = eng.getUser();
        
    String driver=request.getParameter("driver");
    String connurl=request.getParameter("connurl");
    String usr=request.getParameter("usr");
    String pwd=request.getParameter("pwd");
    String tables[]=request.getParameterValues("tables");  
    
    boolean schema=request.getParameter("schema")!=null;
    boolean data=request.getParameter("data")!=null;
    boolean menus=request.getParameter("menus")!=null;
    
    String TABLE[]={"TABLE"};

    Connection conn=null;
    if(driver!=null)
    {
        Class.forName(driver);        
        conn = DriverManager.getConnection(connurl,usr,pwd==null?"":pwd);        
    }
    

//********************************** Ajax Content ************************************************************
    if(request.getParameter("ajax")!=null)
    {
        String _title="JDBC Importer";
        String _fileName=contextPath+"/admin/jsp/JDBCImporter.jsp";        
%>
<!-- Content Header (Page header) -->
<section class="content-header">
    <h1>
        <%=_title%>
        <small></small>
    </h1>
    <ol class="breadcrumb">
        <li><a href="<%=contextPath%>/admin"><i class="fa fa-home"></i>Home</a></li>
        <li>Programación</li>
        <li class="active"><a href="<%=_fileName%>" data-history="#<%=_fileName%>" data-target=".content-wrapper" data-load="ajax"><%=_title%></a></li>
    </ol>
</section>
<!-- Main content -->
<section id="content" style="padding: 7px">  
    <iframe class="ifram_content" src="<%=_fileName%>" frameborder="0" width="100%"></iframe>
    <script type="text/javascript">
        $(window).resize();
    </script>            
</section>
<!-- /.content -->
<%
        //********************************** End Ajax ************************************************************
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" /> 
        <title>JDBC Importer</title>
    </head>
    <body>
        <div class="box-body">
            <div class="col-md-12">
<%
    if(driver==null)
    {
%>
                <form method="POST" role="form">
                  <h4> JDBC Connection Params</h4>
                  <div class="box-body">
                    <div class="form-group">
                        <label for="driver">Driver</label><input name="driver" class="form-control" type="text" value="org.postgresql.Driver">
                    </div>
                    <div class="form-group">
                        <label for="connurl">Connection URL</label><input name="connurl" class="form-control" type="text" value="jdbc:postgresql://localhost/dbcastor_clean">
                    </div>
                    <div class="form-group">
                        <label for="usr">User</label><input name="usr" type="text" class="form-control" value="usrcastor">
                    </div>
                    <div class="form-group">
                        <label for="pwd">Password</label><input name="pwd" type="text" class="form-control" value="">
                    </div>
                    <div class="box-footer">
                      <button type="submit" class="btn btn-primary">Submit</button>
                    </div>
                </form>
<%    
    }else if(tables==null){
%>            
                <form method="POST" action="#">
                    <h4>Tables</h4>
                    <div class="box-body">
                        <div class="form-group">
                            <label for="driver">Schema</label> <input type="checkbox" name="schema"> <span style="width:20">&nbsp</span>
                            <label for="driver">Datos</label> <input type="checkbox" name="data"> <span style="width:20">&nbsp</span>
                            <label for="driver">Menus</label> <input type="checkbox" name="menus"> 
                        </div>
                    <div class="form-group">                                        
                        <input name="driver" type="hidden" value="<%=driver%>">
                        <input name="connurl" type="hidden" value="<%=connurl%>">
                        <input name="usr" type="hidden" value="<%=usr%>">
                        <input name="pwd" type="hidden" value="<%=pwd%>">
                        <select name="tables" multiple size="30" style="width:500px">                
<%
        DatabaseMetaData md = conn.getMetaData();
        //ResultSet rs = md.getTables(null, null, "%", null);
        ResultSet rs = md.getTables(null, null, "%", null);
        while (rs.next()) {
          String squema=rs.getString(2);
          String name=rs.getString(3);
          String type=rs.getString(4);
          String comments=rs.getString(5);

          if("TABLE".equals(type))
          {
              out.print("<option value=\""+squema+"."+name+"\">"+squema+"."+name+(comments!=null?" //"+comments:"")+"</option>");
          }
        }
        rs.close();
%>                    
                        </select>
                    </div> 
                    <div class="form-group">
                        <button type="submit" class="btn btn-primary">Enviar</button>
                    </div> 
                </form>
<%
    }else
    {
        out.println("<pre>");
        try{
            DataList<String> tablesCreated=new DataList();
            if(schema)
            {
                for(String table:tables)
                {
                    out.println("Table:"+table);
                    String squema=table.substring(0,table.indexOf("."));
                    table=table.substring(squema.length()+1);
                    createDataSource(squema, table, out, conn, eng, tablesCreated);
                }
                eng.reloadAllScriptEngines();
            }       

            if(menus)
            {
                if(tablesCreated.isEmpty())
                {
                    for(String table:tables)tablesCreated.add(table);
                }

                for(String table:tablesCreated)
                {
                    out.println("Menu:"+table);
                    String squema=table.substring(0,table.indexOf("."));
                    table=table.substring(squema.length()+1);
                    createMenu(squema, table, out, conn, eng);
                }
            }

            eng.setDisabledDataTransforms(true);
            if(data)
            {
                if(tablesCreated.isEmpty())
                {
                    for(String table:tables)tablesCreated.add(table);
                }

                for(String table:tablesCreated)
                {
                    out.println("Data:"+table);
                    String squema=table.substring(0,table.indexOf("."));
                    table=table.substring(squema.length()+1);
                    importData(squema, table, out, conn, eng);
                }
            }
        }finally
        {
            eng.setDisabledDataTransforms(false);
        }
        out.println("</pre>");
    }
%>            
            </div>
        </div>        
        <!-- jQuery 2.1.4 -->
        <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>        
        <!-- Bootstrap 3.3.2 JS -->
        <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>   
    </body>
</html>
<%
    if(conn!=null)conn.close();
%>
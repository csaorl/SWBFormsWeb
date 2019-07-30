<%@page import="org.semanticwb.datamanager.script.ScriptObject"%>
<%@page import="com.mongodb.util.JSON"%><%@page import="java.io.*"%><%@page import="java.util.*"%><%@page import="org.semanticwb.datamanager.*"%><%@page contentType="text/xml" pageEncoding="UTF-8"%><%!
//global

    /**
     * Lee el contenido del InputStream y lo convierte a un String, con la
     * codificacion especificada
     *
     * @param inputStream
     * @param encoding
     * @return
     * @throws IOException
     */
    public String readInputStream(InputStream inputStream, String encoding) throws IOException {
        return new String(readFully(inputStream), encoding);
    }

    public byte[] readFully(InputStream inputStream) throws IOException {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buffer = new byte[1024];
        int length = 0;
        while ((length = inputStream.read(buffer)) != -1) {
            baos.write(buffer, 0, length);
        }
        return baos.toByteArray();
    }

    DataList getFieldsNames(SWBDataSource ds, boolean folowLinks)
    {
        DataList list=new DataList();
        ScriptObject arr=ds.getDataSourceScript().get("fields");
        if(arr!=null)
        {
            Iterator<ScriptObject> it = arr.values().iterator();
            while (it.hasNext()) {
                ScriptObject obj = it.next();
                String val = obj.getString("name");
                String type = obj.getString("stype");
                String sds= obj.getString("dataSource");
                
                if(folowLinks && type!=null && type.equals("select"))
                {
                    String displayField=ds.getScriptEngine().getDataSource(sds).getDataSourceScript().getString("displayField");
                    if(displayField!=null)val+="."+displayField;
                }
                list.add(val);
            }
        }
        return list;
    }

    String getFieldTitle(String name, SWBDataSource ds)
    {
        int i=name.indexOf('.');
        if(i>-1)
        {
            String base=name.substring(0,i);
            String att=name.substring(i+1);
            String sdsn=ds.getDataSourceScriptField(base).getString("dataSource");
            SWBDataSource sds=ds.getScriptEngine().getDataSource(sdsn);
            return getFieldTitle(att,sds);
        }else
        {
            ScriptObject obj=ds.getDataSourceScriptField(name);
            if(obj!=null)
            {
                return obj.getString("title");
            }else
            {
                return "-";
            }
        }
    }

    String getFieldType(String name, SWBDataSource ds)
    {
        int i=name.indexOf('.');
        if(i>-1)
        {
            String base=name.substring(0,i);
            String att=name.substring(i+1);
            String sdsn=ds.getDataSourceScriptField(base).getString("dataSource");
            SWBDataSource sds=ds.getScriptEngine().getDataSource(sdsn);
            return getFieldType(att,sds);
        }else
        {
            return ds.getDataSourceScriptField(name).getString("type");
        }
    }

    DataList getFieldsTitles(Object oheader, SWBDataSource ds) throws IOException
    {
        DataList list=new DataList();
        if(oheader==null)
        {
            return getFieldsTitles(getFieldsNames(ds,false), ds);
        }else if(oheader instanceof DataList)
        {
            Iterator<String>it=((DataList)oheader).iterator();
            while (it.hasNext()) {
                String att = it.next();           
                list.add(getFieldTitle(att, ds));
            }
        }else if(oheader instanceof DataObject)
        {
            Iterator it=((DataObject)oheader).values().iterator();
            while (it.hasNext()) {
                String title = (String)it.next();           
                list.add(title);
            }
        }
        return list;
    }

    DataList getFieldsTypes(Object oheader, SWBDataSource ds) throws IOException
    {
        DataList list=new DataList();
        if(oheader==null)
        {
            return getFieldsTypes(getFieldsNames(ds,false), ds);
        }else if(oheader instanceof DataList)
        {
            Iterator<String>it=((DataList)oheader).iterator();
            while (it.hasNext()) {
                String att = it.next();           
                list.add(getFieldType(att, ds));
            }
        }else if(oheader instanceof DataObject)
        {
            Iterator it=((DataObject)oheader).values().iterator();
            while (it.hasNext()) {
                String title = (String)it.next();           
                list.add(title);
            }
        }
        return list;
    }

    Object getFieldValue(String name, DataObject rec, SWBDataSource ds) throws IOException
    {
        if(rec==null)return null;
        int i=name.indexOf('.');
        if(i>-1)
        {
            String base=name.substring(0,i);
            String att=name.substring(i+1);            
            String id=rec.getString(base);
            if(id!=null)
            {
                String sdsn=ds.getDataSourceScriptField(base).getString("dataSource");
                SWBDataSource sds=ds.getScriptEngine().getDataSource(sdsn);
                if(id.startsWith("["))  //Contiene multiples valores de ids
                {
                    DataObject query=new DataObject();
                    query.addSubObject("data").addParam("_id", DataObject.parseJSON(id));
                    DataList ret=new DataList();
                    DataObjectIterator it=sds.find(query);
                    while (it.hasNext()) {
                        DataObject obj = it.next();
                        //System.out.println("obj:"+obj);
                        ret.add(getFieldValue(att,obj,sds));
                    }
                    return ret;
                }else
                {
                    DataObject rec2=sds.getObjectById(id);            
                    return getFieldValue(att,rec2,sds);
                }
            }
        }else
        {
            return rec.get(name);
        }
        return null;
    }

    DataList getFieldsValues(DataObject rec, Object oheader, SWBDataSource ds) throws IOException
    {
        DataList list=new DataList();
        if(oheader==null)
        {
            return getFieldsValues(rec, getFieldsNames(ds,false), ds);
        }else if(oheader instanceof DataList)
        {
            Iterator<String>it=((DataList)oheader).iterator();
            while (it.hasNext()) {
                String att = it.next();           
                list.add(getFieldValue(att, rec, ds));
            }
        }else if(oheader instanceof DataObject)
        {
            Iterator it=((DataObject)oheader).keySet().iterator();
            while (it.hasNext()) {
                String att = (String)it.next();           
                list.add(getFieldValue(att, rec, ds));
            }
        }
        return list;
    }

%><%
    DataObject user=(DataObject)session.getAttribute("_USER_");
    
    //init SWBPlatform
    if (DataMgr.getApplicationPath() == null)
    {
        String apppath = config.getServletContext().getRealPath("/");
        DataMgr.createInstance(apppath);
    }            
    
    DataObject json=null;
//    try
//    {
        response.setHeader("Cache-Control", "no-cache");
        response.setHeader("Pragma", "no-cache");
        
        String in=readInputStream(request.getInputStream(),"utf-8");
        json=(DataObject)DataObject.parseJSON(in);
        if(json==null)json=new DataObject();
        
        String dssp = request.getParameter("dssp");
        String ds_s = request.getParameter("ds");  
        String dsint = request.getParameter("dsint");   
        String ext = request.getParameter("ext");
        String fl = request.getParameter("fl");
        if(fl==null)fl="true";
        if(ext==null)ext="xls";
        String data = request.getParameter("data");
        if(data!=null)json=(DataObject)DataObject.parseJSON(data);
        
        System.out.println("json:"+json);
        
        if(dsint==null)dsint="false";
        
        SWBScriptEngine engine=DataMgr.getUserScriptEngine(dssp,user,Boolean.parseBoolean(dsint));
        SWBDataSource ds=engine.getDataSource(ds_s);
        
        DataObject query=json.getDataObject("query");
        Object fields=json.get("fields");
        if(fields==null)fields=getFieldsNames(ds,Boolean.parseBoolean(fl));
        DataList fieldsTitles=getFieldsTitles(fields,ds);
        DataList fieldsTypes=getFieldsTypes(fields,ds);
        if(query==null)query=new DataObject();
        //out.println(ds.fetch(query));
        //out.println(header);
        
        if(ext.equals("xls"))
        {
            response.setHeader("Content-Disposition","attachment; filename=\""+ds_s+".xls\"");
            response.setContentType("application/vnd.ms-excel");

            String iniDoc="<?xml version=\"1.0\"?>\n" +
            "<Workbook xmlns=\"urn:schemas-microsoft-com:office:spreadsheet\"\n" +
            " xmlns:o=\"urn:schemas-microsoft-com:office:office\"\n" +
            " xmlns:x=\"urn:schemas-microsoft-com:office:excel\"\n" +
            " xmlns:ss=\"urn:schemas-microsoft-com:office:spreadsheet\"\n" +
            " xmlns:html=\"http://www.w3.org/TR/REC-html40\">\n" +
            " <Styles>\n"+
            "  <Style ss:ID=\"s66\">\n" +
            "   <Font ss:FontName=\"Calibri\" x:Family=\"Swiss\" ss:Size=\"12\" ss:Color=\"#FFFFFF\"\n" +
            "    ss:Bold=\"1\"/>\n" +
            "   <Interior ss:Color=\"#969696\" ss:Pattern=\"Solid\"/>\n" +
            "  </Style>" +                
            " </Styles>\n"+
            " <Worksheet ss:Name=\"datastream\">\n" +
            "  <Table>\n";

            String iniRow="   <Row>\n";
            String iniCellHead="    <Cell ss:StyleID=\"s66\"><Data ss:Type=\"String\">";
            String endCell="</Data></Cell>\n";
            String endRow="   </Row>\n";    

            String iniCellString="    <Cell><Data ss:Type=\"String\">";
            String iniCellNumber="    <Cell><Data ss:Type=\"Number\">";

            String endDoc="  </Table>\n </Worksheet>\n</Workbook>";              
                        
            //print
            out.print(iniDoc);
            out.print(iniRow);            
            Iterator<String> it=fieldsTitles.iterator();
            while (it.hasNext()) {
                String title = it.next();
                out.print(iniCellHead);
                out.print(title);
                out.print(endCell);                
            }
            out.print(endRow);   
/*            
            out.print(iniRow);            
            it=((DataList)fields).iterator();
            while (it.hasNext()) {
                String name = it.next();
                out.print(iniCellHead);
                out.print(name);
                out.print(endCell);                
            }
            out.print(endRow);            
*/            
            DataObjectIterator it2=ds.find(query);
            while (it2.hasNext()) {
                DataObject rec = it2.next();
                out.print(iniRow);
                DataList values=getFieldsValues(rec, fields, ds);
                
                int i=0;
                Iterator it3=values.iterator();
                while (it3.hasNext()) 
                {
                    Object elem = it3.next();
                    String type=fieldsTypes.getString(i);
                    if(type!=null && (type.equals("int") || type.equals("double") || type.equals("float") || type.equals("long")))
                    {
                        out.print(iniCellNumber);
                    }else
                    {
                        out.print(iniCellString);
                    }
                    if(elem!=null)out.print(elem);
                    out.print(endCell);          
                    i++;
                }
                out.print(endRow);
            }
            out.print(endDoc);        
        }else if(ext.equals("csv"))
        {
            response.setHeader("Content-Disposition","attachment; filename=\""+ds_s+".csv\"");
            response.setContentType("text/csv");

            Iterator<String> it=fieldsTitles.iterator();
            while (it.hasNext()) {
                String title = it.next();
                if(title.indexOf(",")>-1)title="\""+title.replace("\"", "\"\"")+"\"";
                out.print(title);
                if(it.hasNext())out.print(",");                
            }
            out.println();
            
            DataObjectIterator it2=ds.find(query);
            while (it2.hasNext()) {
                DataObject rec = it2.next();
                DataList values=getFieldsValues(rec, fields, ds);
                
                Iterator it3=values.iterator();
                while (it3.hasNext()) 
                {
                    Object elem = it3.next();
                    if(elem!=null)
                    {
                        String val=elem.toString();
                        if(val.indexOf(",")>-1)val="\""+val.replace("\"", "\"\"")+"\"";
                        out.print(val);
                    }
                    if(it3.hasNext())out.print(",");          
                }
                out.println();
            }
        }
/*        
    } catch (Throwable e)
    {
        e.printStackTrace();
        System.out.println("Error"+json);
        DataObject ret=SWBDataSource.getError(-1);
        ret.getDataObject("response").addParam("data", e.getMessage());
        out.print(ret);
    }
*/
%>
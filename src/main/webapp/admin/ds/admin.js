eng.require("/admin/ds/datasources.js",eng.config.dsCache);
eng.require("/admin/ds/admin_base.js",eng.config.dsCache);

//Last, load datasource catalog
if(!eng.isServerSide)
{
    (function(){
        var dss=[];
        var dsFieldData=[];
        for(var att in eng.dataSources)
        {
            dss.push(att);                                  //all datasource
            var ds=eng.dataSources[att];    
            //console.log(ds);
            if(ds.dataSourceBase)ds_dataSources.push(att);  //only db datasources
            if(ds.fields)
            {
                for(var i=0;i<ds.fields.length;i++)
                {
                    dsFieldData.push({"ds":att, "_id":att+"."+ds.fields[i].name, "title":ds.fields[i].title});
                }
            }
        }
        eng.dataSources["ScriptDataSourceField"].cacheData=dsFieldData;
        ds_field_atts_vals.dataSource.valueMap=dss;    

        var vtors=[];
        for(var att in eng.validators)
        {
            vtors.push(att);
        }    
        ds_field_atts_vals.validators.valueMap=vtors;
        
        for(var att in ds_field_atts_vals)
        {
            ds_view_atts.push(att);
            if(!ds_field_atts_vals[att].viewAtt)
            {
                ds_field_atts.push(att);
            }
        }
        
        for(var att in ds_validator_atts_vals)
        {
            ds_validator_atts.push(att);
        }        

    })();
}

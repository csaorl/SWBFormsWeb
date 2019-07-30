//Add your Local dataSource here
/*
eng.dataExtractors["Test"] = {
//    class:"",                    //java class that implements DataExtractor or use extractor by javascript
    scriptEngine:"/admin/ds/datasources.js",
    dataSource:"Log",
    extractor:{                    //extractor by javascript
        start:function(base)
        {
            print("start:");
            print(this);
            print(base);            
        },
        extract:function(base){
            print("extract:");
            print(this);
            print(base);
            //base.store({});       //store data in dataSource
            print(new java.util.Date().getTime());
        },
        stop:function(base)
        {
            print("stop:");
            print(this);
            print(base);            
        }        
    },
    timer:{
        time:5,
        unit:"s"
    }
};
*/

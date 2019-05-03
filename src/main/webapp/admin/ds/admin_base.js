eng.require("/admin/ds/base.js",eng.config.dsCache);

//******* Contants ************
var type_pages = {
    "head": "Head",
    "group_menu": "Group Menu",
    "url_content": "URL Content",
    "ajax_content": "Ajax Content",
    "iframe_content": "IFrame Content",
    "sc_grid": "SC Grid",
    "sc_grid_detail": "SC Grid Detail",
    "sc_form": "SC Form",
};

//Tipos de propiedades o Fields
//type: string, int, date, float, double, long, text      //primitivos
//stype: grid, gridSelect, select, time, file             //extendidos
//Tipos de links, objetos vinculados a formas
//stype: subForm, tab

var ds_dataSources=[];

var ds_field_types = ["boolean","date","double","float","header","int","long","password","section","select","string","time"];

var ds_field_atts_types = ["boolean","date","double","float","int","long","password","select","string","object","time"];

var ds_view_atts=[];

var ds_field_atts = [];

var ds_field_atts_vals={    
    canEdit:{type:"boolean"},
    canEditRoles:{type:"string", editorType:"SelectOtherItem", multiple:true, valueMap:roles},    
    canFilter:{type:"boolean"},
    canViewRoles:{type:"string", editorType:"SelectOtherItem", multiple:true, valueMap:roles},    
    dataSource:{type:"string", editorType:"SelectOtherItem", valueMap:[]},                            //se llena al final
    defaultValue:{type:"string"},
    displayFormat:{type:"string", hint:"value+' '+record.name", showHintInField:"true"},
    editorType:{type:"string", editorType:"SelectOtherItem", valueMap:{"StaticTextItem":"StaticTextItem"}},
    format:{type:"string"},
    formatCellValue:{type:"object", hint:"value+' '+record.name", showHintInField:"true"},   
    helpText:{type:"string"},
    hint:{type:"string"},    
    hoverWidth:{type:"string"},
    icons:{type:"object"},    
    mask:{type:"string"},
    multiple:{type:"boolean"},                                                                              //select
    prompt:{type:"string"},
    redrawOnChange:{type:"boolean"},                                                                        //select
    required:{type:"boolean", viewAtt:true},
    showFilter:{type:"boolean"},
    selectFields:{type:"object"},
    selectWidth:{type:"int"},
    showHintInField:{type:"boolean"},
    showIf:{type:"string"},
    stype:{type:"string", editorType:"SelectOtherItem", valueMap:{"select":"select","gridSelect":"gridSelect","listGridSelect":"listGridSelect","grid":"grid","time":"time","file":"file","text":"text","html":"html","autogen":"autogen","sequence":"sequence","id":"id"}},
    title:{type:"string", viewAtt:true},
    type:{type:"string", viewAtt:true, editorType:"SelectOtherItem", valueMap:ds_field_types},
    validators:{type:"object", editorType:"SelectItem", multiple:true, valueMap:{}},
    valueMap:{type:"object"},                                                                               //select
    width:{type:"string", viewAtt:true},
};

var ds_validator_atts = [];

var ds_validator_types = ["isBoolean","isString","isInteger","isFloat","isFunction",
    "requiredIf", //expression which takes four parameters:
        //item - the DynamicForm item on which the error occurred (may be null)
        //validator - a pointer to the validator object
        //value - the value of the field in question
        //record - the "record" object - the set of values being edited by the widget
    "matchesField", //otherField (should be set to a field name).
    "isOneOf",  //list which should be set to an array of values.
    "regexp",   //expresion
    "integerRange", //min, max, exclusive:true
    "lengthRange",  //min, max
    "mask",     //transformTo
    "custom",   //condition
    "serverCustom", // serverCondition
    "dateRange",    //min max
    "floatRange",   //min max
    
];
var ds_validator_atts_vals={
    expression:{type:"string"},
    list:{type:"object", hint:"['val1','val2']", showHintInField:"true"},
    mask:{type:"string"},    
    max:{type:"int"},
    min:{type:"int"},    
    otherField:{type:"string"},
    transformTo:{type:"string"},
    exclusive:{type:"boolean"},
    condition:{type:"object"},
    serverCondition:{type:"object", hint:"function(name,value,request){return true;}", showHintInField:"true"},
};
var ds_validator_atts_types = ["boolean","double","int","string","object"];

eng.dataSources["DataSourceFieldsExt"] = {
    scls: "DataSourceFieldsExt",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "prop",
    fields: [
        {name: "dsfield", title: "DataSourceField", stype: "select", dataSource:"DataSourceFields"},
        {name: "att", title: "Atributo", type: "selectOther", valueMap:ds_field_atts, 
            change:function(form,item,value){
                var att=ds_field_atts_vals[value];
                if(att)
                {
                    item.grid.setEditValue(item.rowNum,"type",att.type);
                    //form.setValue("type",att.type);
                }
            }
        },
        {name: "value", title: "Valor", type: "string"},
        {name: "type", title: "Tipo de Valor", type: "select", valueMap:ds_field_atts_types},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataSources["DataSourceFields"] = {
    scls: "DataSourceFields",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "title",
    fields: [
        {name: "ds", title: "DataSource", stype: "select", dataSource:"DataSource"},
        {name: "name", title: "Identificador", type: "string"},
        {name: "title", title: "Título", type: "string"},
        {name: "type", title: "Tipo", type: "selectOther", valueMap:ds_field_types},        
        {name: "order", title: "Orden", type: "int"},        
        {name: "required", title: "Requerido", type: "boolean"},        
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataServices["DataSourceFieldsService"] = {
    dataSources: ["DataSourceFields"],
    actions:["add", "update","remove"],
    service: function(request, response, dataSource, action)
    {
        //print("DataSourceFieldsService:"+request.data["_id"]+"->"+action);
        if(action=="remove")
        {
            var it=this.getDataSource("DataSourceFieldsExt").find({data:{dsfield:request.data["_id"]}});
            while(it.hasNext())
            {
                this.getDataSource("DataSourceFieldsExt").removeObj(it.next());
            }
        }
    }
};

eng.dataSources["DataSource"] = {
    scls: "DataSource",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "id",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        {name: "description", title: "Descripción", type: "string"},
        {name: "scls", title: "Nombre de Collección", type: "string"},
        {name: "modelid", title: "Nombre del Modelo", type: "string"},
        {name: "dataStore", title: "Data Store", type: "string"},
        {name: "displayField", title: "Campo de Despliegue", type: "string"},
        //{name: "valueField", title: "Campo de Identificador", type: "string"},
        //{name: "sortField", title: "Campo de Ordenanmiento", type: "string"},
        {name: "backend", title: "Backend", type: "boolean"},
        {name: "frontend", title: "Frontend", type: "boolean"},
        
        {name: "roles_fetch", title: "Roles de Consulta", type: "selectOther", multiple:true, valueMap:roles},
        {name: "roles_add", title: "Roles de Creación", type: "selectOther", multiple:true, valueMap:roles},
        {name: "roles_update", title: "Roles de Edición", type: "selectOther", multiple:true, valueMap:roles},
        {name: "roles_remove", title: "Roles de Eliminación", type: "selectOther", multiple:true, valueMap:roles},
        
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataServices["DataSourceService"] = {
    dataSources: ["DataSource"],
    actions:["add", "update","remove"],
    service: function(request, response, dataSource, action)
    {
        //print("DataSourceService:"+request.data["_id"]+"->"+action);
        if(action=="remove")
        {
            var it=this.getDataSource("DataSourceFields").find({data:{ds:request.data["_id"]}});
            while(it.hasNext())
            {
                this.getDataSource("DataSourceFields").removeObj(it.next());
            }
        }
    }
};

eng.dataSources["ValueMapValues"] = {
    scls: "ValueMapValues",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "id",
    fields: [
        {name: "id", title: "Identificador", validators: [{stype: "id"}], type: "string", required: true},
        {name: "value", title: "Valor", type: "string", required: true},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataSources["ValueMap"] = {
    scls: "ValueMap",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "id",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        {name: "values", title: "Valores", stype: "grid",  dataSource:"ValueMapValues"},        
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};


eng.dataSources["ValidatorExt"] = {
    scls: "ValidatorExt",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "prop",
    fields: [
        {name: "validator", title: "Validator", stype: "select", dataSource:"Validator"},
        {name: "att", title: "Atributo", type: "selectOther", valueMap:ds_validator_atts, 
            change:function(form,item,value){
                var att=ds_validator_atts_vals[value];
                if(att)
                {
                    item.grid.setEditValue(item.rowNum,"type",att.type);
                    //form.setValue("type",att.type);
                }
            }
        },
        {name: "value", title: "Valor", type: "string"},
        {name: "type", title: "Tipo de Valor", type: "select", valueMap:ds_validator_atts_types},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataSources["Validator"] = {
    scls: "Validator",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "name",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        //{name: "name", title: "Nombre", type: "string"},
        {name: "type", title: "Tipo", type: "selectOther", valueMap:ds_validator_types},        
        {name: "errorMessage", title: "Mensaje de Error", type: "string"},        
        {name: "description", title: "Descripción", type: "string"},
        
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ]
};

eng.dataSources["DataService"] = {
    scls: "DataService",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "id",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        {name: "dataSources", title: "DataSources",  multiple:true, type: "selectOther", valueMap:ds_dataSources},        
        {name: "actions", title: "Actions", type: "select",  multiple:true, valueMap:["fetch","add","update","remove"]},        
        {name: "service", title: "Service", stype: "text"},
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataProcessors["DataServiceProcessor"] = {
    dataSources: ["DataService"],
    actions: ["add"],
    request: function (request, dataSource, action)
    {
        if(!request.data.service)request.data.service="function(request, response, dataSource, action){\n    //your code\n}";
        return request;
    },
};

eng.dataSources["DataProcessor"] = {
    scls: "DataProcessor",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "id",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        {name: "dataSources", title: "DataSources",  multiple:true, type: "selectOther", valueMap:ds_dataSources},        
        {name: "actions", title: "Actions", type: "select",  multiple:true, valueMap:["fetch","add","update","remove"]},        
        {name: "request", title: "Request", stype: "text"},
        {name: "response", title: "Response", stype: "text"},
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataProcessors["DataProcessorProcessor"] = {
    dataSources: ["DataProcessor"],
    actions: ["add"],
    request: function (request, dataSource, action)
    {
        if(!request.data.request)request.data.request="function(request, dataSource, action){\n    //your code\n    return request;\n}";
        if(!request.data.response)request.data.response="function(response, dataSource, action){\n    //your code\n    return response;\n}";
        return request;
    },
};

eng.dataSources["PageProps"] = {
    scls: "PageProps",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "prop",
    fields: [
        {name: "prop", title: "Propiedad", stype: "select", multiple:true, dataSource:"ScriptDataSourceField", editorProperties:{sortField:null}, textMatchStyle:"exactCase", getFilterCriteria:function() {
            var ds = form.getValue("ds");
            console.log(ds);
            return {"ds":ds};
        }},
        {name: "att", title: "Atributo", type: "selectOther", valueMap:ds_view_atts, 
            change:function(form,item,value){
                var att=ds_field_atts_vals[value];
                if(att)
                {
                    item.grid.setEditValue(item.rowNum,"type",att.type);
                    //form.setValue("type",att.type);
                }
            }
        },
        {name: "type", title: "Tipo de Valor", type: "select", valueMap:ds_field_atts_types},        
        {name: "value", title: "Valor", type: "string"},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataSources["Page"] = {
    scls: "Page",
    modelid: _modelid,
    dataStore: _dataStore,
    displayField: "name",
    fields: [
        {name: "id", title: "Identificador", type: "string", validators: [{stype: "unique"},{stype: "id"}]},
        {name: "name", title: "Nombre", type: "string"},
        {name: "parentId", title: "Padre", stype: "select", dataSource:"Page", foreignKey:"Page._id",  rootValue_:"home"},
        {name: "smallName", title: "Sub Nombre", type: "string"},
        {name: "status", title: "Estatus", type: "select", valueMap:{active:"Activa",hidden:"Oculta",disabled:"Inactiva"}},        
        {name: "type", title: "Tipo", type: "select", valueMap:type_pages},
        {name: "icon", title: "Icon", type: "string"},
        {name: "iconClass", title: "Clase del Icono", type: "string"},
        {name: "order", title: "Orden", type:"integer", canEdit:"true", hidden:"false"},
        {name: "urlParams", title: "Extra URLParams", type:"string", canEdit:"true", hidden:"false"},
        {name: "roles_view", title: "Roles de Acceso", type: "select", multiple:true, valueMap:roles},
        {name: "path", title: "Ruta del Archivo", type: "string"},        
        //{name: "ds", title: "DataSource", type: "select", editorType: "ComboBoxItem", valueMap:dataSourcesMap},
        {name: "ds", title: "DataSource", type: "selectOther", valueMap:ds_dataSources, changed:"form.clearValue('gridProps');form.clearValue('formProps');"},        
        {name: "gd_conf", title: "Caracteristicas del Grid", type: "select", multiple:true, valueMap:{"inlineEdit":"Editar en Linea", "inlineAdd":"Agregar en linea"}},
        {name: "gridProps", title: "Propiedades del Grid", multiple:true, canReorder_:true, stype: "select", editorType_:"MultiComboBoxItem", layoutStyle_:"verticalReverse", dataSource:"ScriptDataSourceField", textMatchStyle:"exactCase", editorProperties:{sortField:null}, getFilterCriteria:function() {
            //canceled this for use MultiComboBoxItem, defined in onLoad Form
            var ds = this.form.getValue("ds");
            return {"ds":ds};
        }},
        {name: "gridExtProps", title: "Propiedades Extendidas del Grid", stype: "grid", canReorderRecords:true, dataSource:"PageProps"},
        {name: "gridAddiJS", title: "JScript Adicional al Grid", stype: "text"},
        {name: "formProps", title: "Propiedades de la Forma", multiple:true, canReorder_:true, stype: "select", editorType_:"MultiComboBoxItem", layoutStyle_:"verticalReverse", dataSource:"ScriptDataSourceField", textMatchStyle:"exactCase", editorProperties:{sortField:null}, getFilterCriteria:function() {
            //canceled this for use MultiComboBoxItem, defined in onLoad Form
            var ds = this.form.getValue("ds");
            return {"ds":ds};
        }},
        {name: "formExtProps", title: "Propiedades Extendidas de la Forma", stype: "grid", canReorderRecords:true, dataSource:"PageProps"},
        {name: "formAddiJS", title: "JScript Adicionales a la Forma", stype: "text"},
        {name: "roles_add", title: "Roles de Creación", type: "select", multiple:true, valueMap:roles},
        {name: "roles_update", title: "Roles de Edición", type: "select", multiple:true, valueMap:roles},
        {name: "roles_remove", title: "Roles de Eliminación", type: "select", multiple:true, valueMap:roles},
        {name: "created", title: "Fecha de Registro", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "creator", title: "Usuario Creador", type: "string", editorType: "StaticTextItem", canEdit: false},
        {name: "updated", title: "Ultima Actualización", type: "date", editorType: "StaticTextItem", canEdit: false},
        {name: "updater", title: "Usuario Ultima Actualización", type: "string", editorType: "StaticTextItem", canEdit: false},
    ],
    //security:{"fetch":{"roles":["prog"]}, "add":{"roles":["prog"]}, "update":{"roles":["prog"]}, "remove":{"roles":["prog"]}},
};

eng.dataProcessors["PageProcessor"] = {
    dataSources: ["Page"],
    actions: ["add", "update"],
    request: function (request, dataSource, action)
    {
        //print("PageProcessor ini:"+request.data);
        var ndata={};
        for(var att in request.data)
        {
            //print("att:"+att);
            if(att.startsWith("$") || (att.startsWith("_") && att!="_id") || att=="children" || att=="isFolder")
            {
                //print("remove att:"+att);                
            }else
            {
                ndata[att]=request.data[att];
            }
        }
        request.data=ndata;
        if(request.data.type)request.data.icon="/admin/images/"+request.data.type+".png";
        //print("PageProcessor end:"+request.data);
        return request;
    },
};

eng.dataSources["ScriptDataSourceField"]={
    displayField: "title",
    fields:[
        {name:"ds",title:"DataSource",type:"string"},
        {name:"title",title:"Nombre",type:"string"},
    ],
    clientOnly: true,
    cacheAllData:true,
    textMatchStyle:"exactCase",
    defaultTextMatchStyle:"exactCase"
    //cacheData: countryData
};

eng.dataServices["ReloadScriptEngineService"] = {
    dataSources: ["DataSource","DataSourceFields","DataSourceFieldsExt","ValueMap","ValueMapValues","Validator","ValidatorExt","DataProcessor", "DataService"],
    actions:["add", "update","remove"],
    service: function(request, response, dataSource, action)
    {
        //print("needsReloadAllScriptEngines");
        this.needsReloadAllScriptEngines();
    }
};


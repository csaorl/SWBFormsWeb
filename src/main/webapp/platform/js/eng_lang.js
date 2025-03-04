/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
eng.validators["email"] = {type:"regexp", expression:"^([a-zA-Z0-9_.\\-+])+@(([a-zA-Z0-9\\-])+\\.)+[a-zA-Z0-9]{2,4}$",errorMessage:"No es un correo electrónico válido"};
eng.validators["zipcode"] = {type:"regexp", expression:"^\\d{5}(-\\d{4})?$", errorMessage:"El codigo postal debe tener el formato ##### o #####-####."};

eng.fieldProcesors["text"] = function(field)
{
    var base = eng.utils.cloneObject(field);
    
    if (!base.startRow)
        base.startRow=true;
    //if (!base.colSpan)
    //    base.colSpan = 5;
    if (!base.width)
        base.width = "100%";
    if (!base.type)
        //base.type= "AutoFitTextAreaItem";
        base.type= "TextAreaItem";
    return base;
};

eng.fieldProcesors["select"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    var dsObjDef = eng.getDataSourceObjDef(eng.utils.removeAttribute(base, "dataSource"));
    var dsf;
    var dsfmt;
    if(dsObjDef.dsName)
    {
      	var ds = eng.createDataSource(dsObjDef,true,base);
      	dsObjDef.ds=ds;
        if(ds==null)console.log("Undefined DS:",dsObjDef,field);
        else 
        {
          	//console.log(ds);
            dsf=ds.displayField;
            dsfmt=ds.displayFormat;
            ds.canQueueRequests=false;
        }
    }
    
    if(base.displayFormat)dsfmt=base.displayFormat;
    //if(!base.sortby)dsfmt=base.displayFormat;    
    //console.log(dsfmt,base.displayFormat);
    
    
    if(base.multiple===true)                //validar bug de multiple no puede ser requerido
    {
        base.required=false;
    }

    if (!base.editorType)
    {
        if(dsfmt || base.multiple===true)
        {
            base.editorType = "SelectItem";
        }
        else if (base.canFilter != undefined )
        {
            if (base.canFilter === true)
            {
                base.editorType = "ComboBoxItem";
            } else
            {
                base.editorType = "SelectItem";
            }
            eng.utils.removeAttribute(base, "canFilter");
        } else
        {
            base.editorType = "ComboBoxItem";
        }
    }

    //base.displayField = "_" + base.name;
    //base.foreignKey = dsObjDef.dsId + "._id";
    //***** nueva propiedad *********// diaplayName
    //base.editorProperties = {optionDataSource: dsObjDef.dsId, valueField: "_id", displayField: ds.displayField};
    if(!base.valueField)base.valueField="_id";
    
    base.displayField=dsf;
    if(dsfmt)
    {
        base.formatValue= function (value, baserecord, form, item) 
        {   
            var record = item.getSelectedRecord();
            if (record) {
                //console.log("formatValue:"+value,record,dsfmt,item,this);
                if("function" == typeof dsfmt)
                {
                    return dsfmt(value, record);
                }else
                {
                    return eval(dsfmt);
                }
            } else {
               return value;
            }
        };        
    }
    
    //eng.utils.removeAttribute(base, "displayFormat");
    
    base.optionDataSource= dsObjDef.dsId;
        
    if(!base.editorProperties)base.editorProperties={};     
    
    //console.log("1:",base.editorProperties.sortField,!base.editorProperties.sortField,!(base.editorProperties.sortField===null));
    
    if(!base.editorProperties.displayField)base.editorProperties.displayField=dsf;
    if(!base.editorProperties.addUnknownValues)base.editorProperties.addUnknownValues=false; 
    
    if(!base.editorProperties.sortField){
        if(base.editorProperties.sortField===null){
            delete base.editorProperties.sortField
        }else 
        {
            base.editorProperties.sortField=dsf;
        }
    }
    
    //console.log(base.textMatchStyle);
    if(base.textMatchStyle)
    {
        base.editorProperties.textMatchStyle=base.textMatchStyle;  
    }else if(!base.editorProperties.textMatchStyle)
    {
        base.editorProperties.textMatchStyle="substring";
    }    
    
    //console.log(base.name,JSON.stringify(base.editorProperties.sortField));
    
    if(base.getFilterCriteria)
    {
        base.editorProperties.getPickListFilterCriteria=eng.utils.removeAttribute(base, "getFilterCriteria");
    }

    if (base.showFilter)
    {
        base.pickListProperties = {
            showFilterEditor: eng.utils.removeAttribute(base, "showFilter")
        };
    }

    //Campos a mostrar en el despliegue del select (en forma de grid dentro del combo)
    if (base.selectFields)
    {
        base.pickListFields = eng.utils.removeAttribute(base, "selectFields");
    }

    //Tamaño del select una vez desplegado
    if (base.selectWidth)
    {
        base.pickListWidth = eng.utils.removeAttribute(base, "selectWidth");
    }
    
    //Filtrar el resultado del select for un criterio inicial estatico
    if(base.initialCriteria)
    {
        base.optionCriteria = eng.utils.removeAttribute(base, "initialCriteria");
    }
    
//    if(base.dependentSelect)
//    {
//        if(!base.editorProperties)base.editorProperties={};        
//        base.editorProperties.getPickListFilterCriteria = function (p1, p2, p3) 
//        {
//            var ret={};
//            var criterion=this.getCriterion();
//            if(criterion && criterion.operator!="equals")
//            {
//                ret[this.getCriteriaFieldName()]=this.getCriteriaValue();
//            }
//            
//            var field=this.form.getField(base.dependentSelect.dependentField);
//            if(field)
//            {
//                var value=field.getValue();
//                var prop=base.dependentSelect.filterProp;  
//                if(!prop) //si no se define una propiedad se busca la que tenga el mismo DS
//                {
//                    var fieldDS=field.getOptionDataSource().ID;
//                    
//                    for (var attr in this.getOptionDataSource().fields) 
//                    {
//                        var ds=this.getOptionDataSource().fields[attr].optionDataSource;
//                        if(ds==fieldDS)
//                        {
//                            prop=this.getOptionDataSource().fields[attr].name;
//                        }
//                    }                    
//                }
//                if(prop)
//                {
//                    ret[prop]=value;
//                }
//            }
//            return ret;
//        };   
//    }
    
    if(base.dependentSelect)
    {
        var fname=base.dependentSelect;
        var pname=undefined;
        //si recibe un objeto con los parametros dependentField, filterProp en lugar de un string con el valor por default de dependentField
        if("object" == typeof fname)
        {
            fname=base.dependentSelect.dependentField;
            pname=base.dependentSelect.filterProp;
        }
        
        base.changed=function(form,item,value)
        {
            var ret={};
            var field=form.getField(fname);
            field.setValue(null);
            if(!pname) //si no se define una propiedad se busca la que tenga el mismo DS
            {
                for (var attr in field.getOptionDataSource().fields) 
                {
                    var ds=field.getOptionDataSource().fields[attr].optionDataSource;
                    if(ds==item.optionDataSource)
                    {
                        pname=field.getOptionDataSource().fields[attr].name;
                    }
                }    
            }
            ret[pname]=value;
            field.optionCriteria=ret;
        }
        
        base.formatEditorValue=function(value,record,form,item,grid)
        {
            if(value && !grid)
            {
                var field=form.getField(fname);
                if(field && !field.optionCriteria)
                {
                    var ret={};
                    if(!pname) //si no se define una propiedad se busca la que tenga el mismo DS
                    {
                        for (var attr in field.getOptionDataSource().fields) 
                        {
                            var ds=field.getOptionDataSource().fields[attr].optionDataSource;
                            if(ds && ds==item.optionDataSource)
                            {
                                pname=attr;
                            }
                        }    
                    }
                    ret[pname]=value;
                    field.optionCriteria=ret;            
                }
            }else if(grid)
            {
                var field=grid.getField(fname);
                if(field && form!=field._lastFilterCriterial)
                {
                    field._lastFilterCriterial=form;
                    var ret={};
                    if(!pname) //si no se define una propiedad se busca la que tenga el mismo DS
                    {
                        var dsf=DataSource.get(field.optionDataSource).fields;
                        for (var attr in dsf) 
                        {
                            var ds=dsf[attr].optionDataSource;
                            if(ds && ds==grid.getCellField(form,item).optionDataSource)
                            {
                                pname=attr;
                            }
                        }    
                    }
                    ret[pname]=value;
                    field.optionCriteria=ret;            
                }
            }
            return value;
        }
    }    

    return base;
};

eng.fieldProcesors["multiSelect"] = function(field)
{
    var base = eng.utils.cloneObject(field);
    base.multiple=true;    

    var dsObjDef = eng.getDataSourceObjDef(eng.utils.removeAttribute(base, "dataSource"));
    var dsf;
    var dsfmt;
    if(dsObjDef.dsName)
    {
      	var ds = eng.createDataSource(dsObjDef,true,base);
      	dsObjDef.ds=ds;
        if(ds==null)console.log("Undefined DS:",dsObjDef,field);
        else 
        {
          	//console.log(ds);
            dsf=ds.displayField;
            dsfmt=ds.displayFormat;
            ds.canQueueRequests=false;
        }
    }
    
    if(base.displayFormat)dsfmt=base.displayFormat;  
    
    if (!base.editorType)
        base.editorType = "MultiComboBoxItem";    
    
    if(!base.valueField)base.valueField="_id";
    
    base.displayField=dsf;
    if(dsfmt)
    {
        base.formatValue= function (value, baserecord, form, item) 
        {   
            var record = item.getSelectedRecord();
            if (record) {
                //console.log("formatValue:"+value,record,dsfmt,item,this);
                if("function" == typeof dsfmt)
                {
                    return dsfmt(value, record);
                }else
                {
                    return eval(dsfmt);
                }
            } else {
               return value;
            }
        };        
    }
    
    base.optionDataSource= dsObjDef.dsId;
        
    if(!base.comboBoxProperties)base.comboBoxProperties={};     
    
    //console.log("1:",base.editorProperties.sortField,!base.editorProperties.sortField,!(base.editorProperties.sortField===null));
    
    if(!base.comboBoxProperties.displayField)base.comboBoxProperties.displayField=dsf;
    if(!base.comboBoxProperties.addUnknownValues)base.comboBoxProperties.addUnknownValues=false; 
    
    if(!base.comboBoxProperties.sortField){
        if(base.comboBoxProperties.sortField===null){
            delete base.comboBoxProperties.sortField
        }else 
        {
            base.comboBoxProperties.sortField=dsf;
        }
    }
    
    //console.log(base.textMatchStyle);
    if(base.textMatchStyle)
    {
        base.comboBoxProperties.textMatchStyle=base.textMatchStyle;  
    }else if(!base.comboBoxProperties.textMatchStyle)
    {
        base.comboBoxProperties.textMatchStyle="substring";
    }    
    
    //console.log(base.name,JSON.stringify(base.editorProperties.sortField));
    
    if(base.getFilterCriteria)
    {
        base.comboBoxProperties.getPickListFilterCriteria=eng.utils.removeAttribute(base, "getFilterCriteria");
    }

    if (base.showFilter)
    {
        base.comboBoxProperties.pickListProperties = {
            showFilterEditor: eng.utils.removeAttribute(base, "showFilter")
        };
    }

    //Campos a mostrar en el despliegue del select (en forma de grid dentro del combo)
    if (base.selectFields)
    {
        base.comboBoxProperties.pickListFields = eng.utils.removeAttribute(base, "selectFields");
    }

    //Tamaño del select una vez desplegado
    if (base.selectWidth)
    {
        base.comboBoxProperties.pickListWidth = eng.utils.removeAttribute(base, "selectWidth");
    }
    
    //Filtrar el resultado del select for un criterio inicial estatico
    if(base.initialCriteria)
    {
        base.optionCriteria = eng.utils.removeAttribute(base, "initialCriteria");
    }

    return base;    
}

eng.fieldProcesors["grid"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.editorType)
        base.editorType = "GridEditorItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "250";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    if (base.canReorderRecords===undefined)
        base.canReorderRecords = true;
    return base;
};

eng.fieldProcesors["gridView"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.editorType)
        base.editorType = "GridViewItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "150";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    return base;
};

eng.fieldProcesors["gridSelect"] = function(field)
{
    var base = eng.utils.cloneObject(field);
    
    var dsObjDef = eng.getDataSourceObjDef(eng.utils.removeAttribute(base, "dataSource"));
    var ds;
    var dsf;
    if(dsObjDef.dsName)
    {
        ds = eng.createDataSource(dsObjDef,true,base);
        dsObjDef.ds=ds;
        if(ds==null)console.log("Undefined DS:",dsObjDef,field);
        else dsf=ds.displayField;  
    }

    if(!base.valueField)base.valueField="_id";
    base.displayField= dsf;
    
    if(base.displayFormat)
    {
        base.formatValue= function (value, baserecord, form, item) 
        {   
            var record = item.getSelectedRecord();
            if (record) {
                //console.log(selectedRecord);
                if("function" == typeof base.displayFormat)
                {
                    return base.displayFormat(value, record);
                }else
                {
                    return eval(base.displayFormat);
                }
            } else {
               return value;
            }
        };        
    }
    
    base.dsDef=dsObjDef;
    base.optionDataSource= dsObjDef.dsId;

    if (!base.editorType)
        base.editorType = "GridSelectItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "250";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    return base;
};

eng.fieldProcesors["listGridSelect"] = function(field)
{
    var base = eng.utils.cloneObject(field);
    
    var dsObjDef = eng.getDataSourceObjDef(eng.utils.removeAttribute(base, "dataSource"));
    var ds;
    var dsf;
    if(dsObjDef.dsName)
    {
        ds = eng.createDataSource(dsObjDef,true,base);
        dsObjDef.ds=ds;
        if(ds==null)console.log("Undefined DS:",dsObjDef,field);
        else dsf=ds.displayField;  
    }

    if(!base.valueField)base.valueField="_id";
    base.displayField= dsf;
    
    if(base.displayFormat)
    {
        base.formatValue= function (value, baserecord, form, item) 
        {   
            var record = item.getSelectedRecord();
            if (record) {
                //console.log(selectedRecord);
                if("function" == typeof base.displayFormat)
                {
                    return base.displayFormat(value, record);
                }else
                {
                    return eval(base.displayFormat);
                }
            } else {
               return value;
            }
        };        
    }
    
    base.dsDef=dsObjDef;
    base.optionDataSource= dsObjDef.dsId;

    if (!base.editorType)
        base.editorType = "ListGridSelectItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "250";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    return base;
};

eng.fieldProcesors["time"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.type)
        base.type = "time";
    if (!base.minuteIncrement)
        base.minuteIncrement = 15;
    if (!base.useTextField)
        base.useTextField = false;
    return base;
};

eng.fieldProcesors["file"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.editorType)
        //base.editorType = "FileItem2";
        base.editorType = "FileUpload";
//    if (!base.width)
//        base.width = "100%";
//    if (!base.height)
//        base.height = "20";
//    if (!base.startRow)
//        base.startRow = true;
//    if (!base.colSpan)
//        base.colSpan = 5;
    base.validators=[{
            type:"custom",
            condition:function(field,validator,value,p4)
            {
                if(Array.isArray(value))
                {
                    for(var i=0;i<value.length;i++)
                    {
                        var f=value[i];
                        if(f.percent && f.percent<100)return false;
                    }
                }
                return true;
            },
            errorMessage:"Carga de archivo en proceso..."
         }];

    base.formatCellValue=function(value, record, row, col)
    {
        console.log("formatCellValue",value);                
        var ret="";
        if(Array.isArray(value))
        {
            for(var i=0;i<value.length;i++)
            {
                var f=value[i];
                ret+="<a style=\"color: #404040;text-decoration: none;\" target=\"_new\" href=\"/"+ eng.contextPath + "fd/" + f.id + "/"+f.name+"\">"+f.name;
                if(f.percent)ret+=" ("+f.percent+"%)";
                ret+="</a>";
                if(i<value.length-1)ret+=", ";
            }
        }
        return ret;
    };
//    
//    base.formatEditorValue=function()
//    {
//        return "Hola2";
//    };    

    return base;
};

eng.fieldProcesors["html"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.editorType)
        //base.editorType = "FileItem2";
        base.editorType = "RichTextItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "200";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    if (!base.showTitle)
        base.showTitle=true;
    return base;
};

eng.fieldProcesors["googleMaps"] = function(field)
{
    var base = eng.utils.cloneObject(field);

    if (!base.editorType)
        base.editorType = "GoogleMapsItem";
    if (!base.width)
        base.width = "100%";
    if (!base.height)
        base.height = "300";
    if (!base.startRow)
        base.startRow = true;
    if (!base.colSpan)
        base.colSpan = 5;
    return base;
};


//*********** GridEditorItem ***********************************
isc.ClassFactory.defineClass("GridEditorItem", "CanvasItem");

isc.GridEditorItem.addProperties({
    height:"*", 
    width:"*",
    rowSpan:"*", 
    endRow:true, 
    startRow:true,
    winEdit: false,
    //canEdit: "*",
    
    // this is going to be an editable data item
    shouldSaveValue:true,
    
    // Implement 'createCanvas' to build a ListGrid from which the user may 
    // select items.
    createCanvas : function () {
        this.dataSourceName = this.dataSource;
        this.dataSource = eng.createDataSource(this.dataSource,true,this);
        
        //console.log(this);
           
        var canEdit=this.canEdit!==undefined?this.canEdit:this.form.canEdit!==undefined?this.form.canEdit:true;   
        
        this.canEdit=true;
        
        //console.log(canEdit);
        
        var totalsLabel = isc.Label.create({
            padding: 5,
        });
        
        var toolStrip = null;
        
        if(canEdit)
        {
            this.editButton=isc.ToolStripButton.create({
                icon: "[SKIN]/actions/edit.png",
                prompt: "Edit registro seleccionado",
                click: function() {
                    if (this.parentElement.parentElement.winEdit)
                    {
                        var record = this.parentElement.parentElement.getSelectedRecord();
                        var field=this.parentElement.parentElement.canvasItem;
                        //if(!field.winEdit.fields)field.winEdit.fields=eng.filterFields(field.originalFields);
                        //if(!field.winEdit.title)field.winEdit.fields=field.title;
                        var win=eng.editWindowForm(field.winEdit,record._id,field.dataSourceName);
                        if (win.form != null)
                        {
                            win.form.fromGrid = this.parentElement.parentElement;
                        }
                    } else
                    {
                        var record = this.parentElement.parentElement.getSelectedRecord();
                        if (record == null)
                            return;
                        this.parentElement.parentElement.startEditing(this.parentElement.parentElement.data.indexOf(record));
                    }
                }
            });      

            
            var mem=[totalsLabel,
                    isc.LayoutSpacer.create({
                        width: "*"
                    })];
                
            if(this.canAdd!==false)
            {
                this.addButton=isc.ToolStripButton.create({
                    icon: "[SKIN]/actions/add.png",
                    prompt: "Agregar nuevo registro",
                    click: function() {
                        //console.log(this);
                        var g=this.parentElement.parentElement;
                        var field=g.canvasItem;
                        if (g.winEdit)
                        {                            
                            //if(!field.winEdit.fields)field.winEdit.fields=eng.filterFields(field.originalFields);
                            //if(!field.winEdit.title)field.winEdit.fields=field.title;
                            var win=eng.editWindowForm(field.winEdit,null,field.dataSourceName);
                            //var win=eng.editWindowForm(field.winEdit,null,field.dataSource,eng.utils.copyAttributes(field.winEdit.values,eng.utils.copyAttributes(g.initialCriteria,{})));
                            if (win.form != null)
                            {
                                win.form.fromGrid = this.parentElement.parentElement;
                            }
                        } else
                        {
                            g.startEditingNew();
                            //g.startEditingNew(eng.utils.copyAttributes(field.values,eng.utils.copyAttributes(g.initialCriteria,{})));
                        }
                    }
                });   
                
                if(this.addButtonClick!==undefined)
                {
                    this.addButton.click = this.addButtonClick;
                }                
                
                mem.push(this.addButton);
            }
            mem.push(this.editButton);
            
            if(this.canRemove!==false)
            {
                this.removeButton=isc.ToolStripButton.create({
                    icon: "[SKIN]/actions/remove.png",
                    prompt: "Eliminar registro seleccionado",
                    click: function() {
                        var records = this.parentElement.parentElement.getSelection();
                        if (records == null)
                            return;

                        for (var i = records.length; i--; )
                        {
                            var record = records[i];
                            this.parentElement.parentElement.markRecordRemoved(this.parentElement.parentElement.data.indexOf(record));
                        }
                        //this.parentElement.parentElement.removeSelectedData();
                    }
                });    
                mem.push(this.removeButton);
            }
            
            toolStrip = isc.ToolStrip.create({
                width: "100%",
                height: 24,
                members: mem
            });
        }else       
        {
            toolStrip = isc.ToolStrip.create({
                width: "100%",
                height: 24,
                members: [
                    totalsLabel,
                    isc.LayoutSpacer.create({
                        width: "*"
                    })
                ]
            });            
        }
        
        var _this=this;
                        
        var grid= isc.ListGrid.create({
            //autoDraw:false,            

            width:this.width, 
            height:this.height,
            // fill the space the form allocates to the item
            leaveScrollbarGaps:false,
            
            // dataSource and fields to use, provided to a listGridItem as
            // listGridItem.gridDataSource and optional gridFields
            dataSource:this.dataSource,
            //dataSource:eng.createDataSource(this.dataSource,true,this),
            fields:this.fields,
            autoFetchData:false,
            alternateRecordStyles: this.alternateRecordStyles?this.alternateRecordStyles:true,
            warnOnRemoval:true,
            sortField: this.gridSortField,
            // the record being edited is assumed to have a set of subrecords
            //data:this.getValue(),
            canEdit:canEdit,
            winEdit: this.winEdit,
            autoSaveEdits: false,
            gridComponents: ["filterEditor","header", "body","summaryRow", toolStrip],
            //autoFitData: "vertical",
            //autoFitMaxRecords: 5,
            initialCriteria: this.initialCriteria,
            showRecordComponents:this.showRecordComponents,
            showRecordComponentsByCell:this.showRecordComponentsByCell,
            createRecordComponent:this.createRecordComponent,
            groupStartOpen:this.groupStartOpen,
            groupByField:this.groupByField,     
            showGridSummary:this.showGridSummary,
            wrapCells:this.wrapCells,
            editEvent:this.editEvent,
            editByCell:this.editByCell,
            canReorderFields:this.canReorderFields,
            canReorderRecords:this.canReorderRecords,
            canResizeFields:this.canResizeFields,
            canSort:this.canSort,
            canSelect:this.canSelect,
            baseStyle:this.baseStyle,
            canRemoveRecords:canEdit && this.canRemove!==false,
            headerSpans:this.headerSpans,
            editByCell:this.editByCell,            
            visibility:this.visibility?this.visibility:"hidden",            
            
            recordDoubleClick: function(viewer, record, recordNum, field, fieldNum, value, rawValue)
            {
                if (this.canvasItem.winEdit)
                {
                    var field=this.canvasItem;
                    //if(!field.winEdit.fields)field.winEdit.fields=eng.filterFields(field.originalFields);
                    //if(!field.winEdit.title)field.winEdit.fields=field.title;
                    var win=null;
                    if(record && record!=null)
                    {
                        win=eng.editWindowForm(field.winEdit,record._id,field.dataSourceName);
                    }else
                    {
                        win=eng.editWindowForm(field.winEdit,null,field.dataSourceName, viewer.getEditValues(recordNum));
                    }
                    if (win.form != null)
                    {
                        win.form.fromGrid = this;
                    }                    
                }else
                {
                    //console.log(this,record,recordNum);
                    if(this.canEdit)
                    {
                        this.startEditing(recordNum);
                    }
                    //this.parentElement.parentElement.startEditing(this.parentElement.parentElement.data.indexOf(record));
                }
            },
            dataChanged: this.dataChanged?this.dataChanged:function()
            {
                this.Super("dataChanged", arguments);
                var totalRows = this.data.getLength();
                if (totalRows > 0 && this.data.lengthIsKnown()) {
                    totalsLabel.setContents(totalRows + " Registros");
                } else {
                    totalsLabel.setContents(" ");
                }
            },            
            
            recordDrop : function (draggedRecords, targetRecord, targetIndex, sourceWidget) {
                // Call the super implementation of recordDrop() to update the order of rows in the ListGrid.
                this.Super("recordDrop", arguments);
                
                console.log(this,_this);
                var val=[];
                for(var x=0;x<grid.data.localData.length;x++)
                {
                    val.push(grid.data.localData[x]._id);
                }
                _this.form.setValue(_this.name,val);
                console.log(val);
            }
                      
        });                
        
        if(this.getEditorProperties!==undefined)
        {
            grid.getEditorProperties=this.getEditorProperties;
        }
        
        if(this.cellHeight!==undefined)
        {
            grid.cellHeight = this.cellHeight;
        }
        
        if(this.headerHeight!==undefined)
        {
            grid.headerHeight = this.headerHeight;
        }
        
        if(this.recordDoubleClick!==undefined)
        {
            grid.recordDoubleClick = this.recordDoubleClick;
        }  
        
        if(this.removeRecordClick!==undefined)
        {
            grid.removeRecordClick = this.removeRecordClick;
        } 
        
        if(this.listEndEditAction!==undefined)
        {
            grid.listEndEditAction = this.listEndEditAction;
        } 
        
        if(this.enterKeyEditAction!==undefined)
        {
            grid.enterKeyEditAction = this.enterKeyEditAction;
        }         
        
        grid.form=this.form;
        grid.canvasItem=this;
        this.grid=grid;
        eng.linkFormGrid(this.form, this.grid);
        
        if (this.winEdit)
        {
            grid.canEdit = false;
        }          
        
        return grid;        
    },
    
    isEditable:function()
    {
        return this.canvas.canEdit;
    },    
    
    validate: function()
    {
        this.grid.endEditing();
        //validar nuevos registros borrados
        for (i = 0; i < this.grid.getAllEditRows().length; i++)
        {
            var earr = this.grid.getAllEditRows();
            if (this.grid.recordMarkedAsRemoved(earr[i]) == true && this.grid.getRecord(earr[i]) == null)
            {
                this.grid.discardEdits(earr[i])
                i--;
            }
        }

        var earr = this.grid.getAllEditRows();
        for (i = 0; i < earr.length; i++)
        {
            if (this.grid.recordMarkedAsRemoved(earr[i]) == false && this.grid.validateRow(earr[i]) == false)
            {
                var err = this.grid.getRowValidationErrors(earr[i]);
                err.form = this.grid;
                eng.validates.errors.push(err);
                return false;
            }
        }
        return true;
    },
    
    
    // implement showValue to update the ListGrid selection
    showValue : function (displayValue, dataValue) {
        if (this.canvas == null) return;
      
      	if((!dataValue || dataValue==null)&& this.grid.getAllEditRows().length>0)return;

        if (this.grid.invalidate == false && this.dataValue && dataValue && this.dataValue.toString() == dataValue.toString())
            return; //comparar si cambio o no el contenido

        if (dataValue && dataValue.length>0)
        {
            this.grid.discardAllEdits(null);
            this.dataValue = dataValue;
            try {
                this.grid.invalidateCache();
            }
            catch(err) {
                console.log(err);
            }
            
            //if(dataValue==null)dataValue="";
            if(dataValue != null)
            {
                this.grid.invalidate = false;  //bandera para recargar cache   
                if("string" == typeof dataValue)
                {
                    console.log(dataValue,this);
                    dataValue=dataValue.split(",");                    
                    this.form.setValue(this.name,dataValue);
                    this.dataValue=dataValue;
                    console.log(dataValue,this);
                }

                this.grid.fetchData({
                    _id: dataValue
                },
                function(dsResponse, data, dsRequest)
                {
//                    var grid = isc.eval(dsRequest.componentId);
//                    for (i = 0; i < data.length; i++)
//                    {
//                        if (data[i]._id.endsWith("_biz"))
//                        {
//                            grid.data.localData[i] = {
//                                _id: data[i]._id
//                            };
//                            grid.setEditValues(i, data[i]);
//                        }
//                    }
                });
            }
        }else
        //else if (null==dataValue)
        {
            this.dataValue=null;
            this.grid.discardAllEdits(null);
            //this.grid.setCriteria({_id:""})
            this.grid.setData([]);
        }
    }
    
});

//*********** GridViewItem ***********************************
isc.ClassFactory.defineClass("GridViewItem", "CanvasItem");

isc.GridViewItem.addProperties({
    height:"*", 
    width:"*",
    rowSpan:"*", 
    endRow:true, 
    startRow:true,
    
    // Implement 'createCanvas' to build a ListGrid from which the user may 
    // select items.
    createCanvas : function () {
        var grid= isc.ListGrid.create({
            width:this.width, 
            height:this.height,
            leaveScrollbarGaps:false,
            fields:this.fields,
            autoFetchData:false,
            alternateRecordStyles: this.alternateRecordStyles?this.alternateRecordStyles:true,
            sortField: this.gridSortField,
            autoSaveEdits: false,
            cellHeight:this.cellHeight,
            autoFitData: "vertical",
            autoFitMaxRecords: 5,
            initialCriteria: this.initialCriteria,
            showRecordComponents:this.showRecordComponents,
            showRecordComponentsByCell:this.showRecordComponentsByCell,
            createRecordComponent:this.createRecordComponent,
            groupStartOpen:this.groupStartOpen,
            groupByField:this.groupByField,     
            showGridSummary:this.showGridSummary,
            wrapCells:this.wrapCells,
            canReorderFields:this.canReorderFields,
            canResizeFields:this.canResizeFields,
            canSort:this.canSort,
            canSelect:this.canSelect,
            baseStyle:this.baseStyle,
            headerHeight:this.headerHeight?this.headerHeight:25,
            headerSpans:this.headerSpans,
            visibility:this.visibility?this.visibility:"hidden",
            data:this.data,
            //showFilterEditor: this.showFilter,
        });
        
        if(this.recordDoubleClick!==undefined)
        {
            grid.recordDoubleClick = this.recordDoubleClick;
        }   
        
        if(this.removeRecordClick!==undefined)
        {
            grid.removeRecordClick = this.removeRecordClick;
        }         
        
        grid.form=this.form;
        grid.canvasItem=this;
        this.grid=grid;
        //eng.linkFormGrid(this.form, this.grid);
        return grid;        
    },
    
    isEditable:function()
    {
        return false;
    },    
    
    /*
    // implement showValue to update the ListGrid selection
    showValue : function (displayValue, dataValue) {
        if (this.canvas == null) return;
      
      	if((!dataValue || dataValue==null)&& this.grid.getAllEditRows().length>0)return;

        if (this.grid.invalidate == false && this.dataValue && dataValue && this.dataValue.toString() == dataValue.toString())
            return; //comparar si cambio o no el contenido

        if (dataValue && dataValue.length>0)
        {
            this.grid.discardAllEdits(null);
            this.dataValue = dataValue;
            this.grid.invalidateCache();
            //if(dataValue==null)dataValue="";
            if(dataValue != null)
            {
                this.grid.invalidate = false;  //bandera para recargar cache            
                this.grid.fetchData({
                    _id: dataValue
                },
                function(dsResponse, data, dsRequest)
                {
//                    var grid = isc.eval(dsRequest.componentId);
//                    for (i = 0; i < data.length; i++)
//                    {
//                        if (data[i]._id.endsWith("_biz"))
//                        {
//                            grid.data.localData[i] = {
//                                _id: data[i]._id
//                            };
//                            grid.setEditValues(i, data[i]);
//                        }
//                    }
                });
            }
        }else
        //else if (null==dataValue)
        {
            this.dataValue=null;
            this.grid.discardAllEdits(null);
            //this.grid.setCriteria({_id:""})
            this.grid.setData([]);
        }
    }
    */
    
});


//*********** FileUpload ***********************************
//                maxFileSize : '10mb',
//                filters : { 
//                        mime_types: [
//                                {title : "Image files", extensions : "jpg,gif,png"},
//                                {title : "Zip files", extensions : "zip"}
//                        ]
//                },
//**********************************************************
isc.ClassFactory.defineClass("FileUpload", "CanvasItem");

isc.FileUpload.addProperties({
    width: "*",
    height: "*",
    padding: "*",
    shouldSaveValue: true,
    startRow:true,
    colSpan:5,
    discardEditsOnHideField:false,
    filters:{mime_types:[]},
    //onUploadComplete                           //parameter callback
    //canEdit:true,
    // Implement 'createCanvas' to build a ListGrid from which the user may 
    // select items.
    
    
    createCanvas: function()
    {
        console.log("createCanvas");        
        var c = isc.HTMLFlow.create({
            width: this.width,
            height: this.height,
            padding: this.padding,
            //overflow:"auto",
            canDragResize: true,
            showEdges: false,
            autoDraw:false,
            canEdit:this.canEdit!==undefined?this.canEdit:this.form.canEdit!==undefined?this.form.canEdit:true,
        });
        
        return c;

    },
    
    isEditable:function()
    {
        return this.canvas.canEdit;
    },
    
    remove: function(id)
    {
        console.log("remove");                
        var vals=this.canvas.canvasItem.form.getValue(this.canvas.canvasItem.name);
        var ret=[];
        for(var i=0;i<vals.length;i++)
        {
            var f=vals[i];
            if(f.id!==id)
            {
                ret.push(f);
            }
        }
        this.canvas.canvasItem.form.setValue(this.canvas.canvasItem.name,ret);
        this.canvas.uploader.removeFile(id);
    }, 
    
//    formatEditorValue: function(value, record, form, item)
//    {
//        return "hola";
//    },
    
//    formatValue: function(value, record, form, item)
//    {
//        //if(value)
//            return "hola";
//    },    
    
    // implement showValue to update the ListGrid data
    // Note that in this case we care about the underlying data value - an array of records
    showValue: function(displayValue, dataValue,p1,p2,p3)
    {
        console.log("showValue:", displayValue, dataValue);
        if (this.canvas == null)
            return;    
        
        var content="";
        if(dataValue)
        {
            if(Array.isArray(dataValue))
            {
                for(var i=0;i<dataValue.length;i++)
                {
                    var p=100;
                    if(dataValue[i].percent)p=dataValue[i].percent;
                    
                    content += "        <span><a style=\"color: #404040;text-decoration: none;\" target=\"_new\" href=\""+ eng.contextPath + "/fd/" + dataValue[i].id + "/"+encodeURI(dataValue[i].name)+"\">" + dataValue[i].name + "</a>";
                    if(p<100)content+=" ("+p+")";
                    if(this.isEditable())content += "<img style=\"margin-left: 2px; cursor: pointer; vertical-align: middle;\" onClick=\"" + this.ID + ".remove('"+dataValue[i].id+"');\" src=\"" + eng.contextPath + "/platform/isomorphic/skins/Tahoe/images/actions/close.png\"/>";
                    if(i<dataValue.length-1)content+=",";
                    content += "        </span>";
                    
//                    content += 
//                            "<div style=\"width:100%; height:15px; border:1px solid #909090; overflow:hidden;\">" +
//                            "    <div id=\"" + this.ID + "_percentage\" style=\"width:"+p+"%; height:15px; background: #f0f0f0;\"></div>" +
//                            "    <div id=\"" + this.ID + "_label\" style=\"color: #FFFFFF; font-size: 12px; left: 5px; position: relative; top: -15px;\">";
//
//                    content += "        <span style=\"float:left\"><a style=\"color: #404040;text-decoration: none;\" target=\"_new\" href=\"/uploadfile/" + dataValue[i].id + "\">" + dataValue[i].name + "</a></span>";
//                    if(this.isEditable())content += "        <span onClick=\"" + this.ID + ".remove('"+dataValue[i].id+"');\" style=\"cursor: pointer; color: #000000; position:absolute; top:-1px; right:5px; \"><img src=\"/isomorphic/skins/Tahoe/images/actions/remove.png\"/></span>";
//                    content += "     </div></div>";
//                    content += "</div>";


                }
            }
        }
        
        if(this.isEditable())content="<button onclick=\""+this.ID+"_button.click()\">Cargar Archivo</button>"+content;
        //content = "<div style=\"width:100%; height:18px; overflow:hidden;\">"+content+"</div>";
        content = "<div style=\"width:100%; height:18px;\">"+content+"</div>";
        this.canvas.setContents(content);
        
        //console.log(dataValue);  
        if(this.isEditable() && !this.canvas.uploader)this.initUploader(this.canvas);
    },
    
    
    initUploader:function(canvas)
    {
        console.log("initUploader:",this.ID);                
        
        var div=document.createElement("div");
        div.innerHTML=
            "<div id=\""+this.ID+"_container\" style=\"display:none\">\n" +
            "    <button id=\""+this.ID+"_button\">Elegir Archivos</button> \n" +
            "</div>\n";
    
        var old=document.getElementById(this.ID+"_container");
        if(old)old.remove();
        document.body.appendChild(div);        
        
        var uploader = new plupload.Uploader({
                runtimes : 'html5,flash,silverlight,html4',
                browse_button : this.ID + "_button", // you can pass in id...
                container: this.ID + "_container", // ... or DOM Element itself
                url : eng.contextPath + '/platform/jsp/plupload.jsp',
                flash_swf_url : eng.contextPath + '/platform/plupload/js/Moxie.swf',
                silverlight_xap_url : eng.contextPath + '/platform/pluploadjs/Moxie.xap',
                chunk_size: '4mb',
                //max_file_size : '10mb',
                unique_names: true,
                
                max_file_size : this.maxFileSize,
                filters: this.filters,

//                filters : {
//                        //max_file_size : '10mb',
//                        mime_types: [
//                                {title : "Image files", extensions : "jpg,gif,png"},
//                                {title : "Zip files", extensions : "zip"}
//                        ]
//                },

                init: {
                        PostInit: function() {
                            //console.log("PostInit");
                        },

                        FilesAdded: function(up, files) {
                            //console.log("FilesAdded",up,files);
                            var vals;
                            
//                            if(this.canvas.canvasItem.grid)
//                            {
//                                vals=this.canvas.canvasItem.grid.getEditForm().values[this.canvas.canvasItem.name];
//                            }else
//                            {
                                vals=this.canvas.canvasItem.form.getValue(this.canvas.canvasItem.name);
//                            }
                            
                            if(!(Array.isArray(vals)))
                            {
                                vals=[];
                            }else
                            {
                                vals=eng.utils.cloneObject(vals);
                            }
                            
                            for(var i=0;i<files.length;i++)
                            {
                                var f=files[i];
                                if(this.canvas.canvasItem.grid)
                                {
                                    f.grid={rowNum:this.canvas.canvasItem.rowNum,colNum:this.canvas.canvasItem.colNum};
                                }
                                vals.push({id:f.id,name:f.name,lastModifiedDate:f.lastModifiedDate,size:f.size,target_name:f.target_name,type:f.type,percent:f.percent});
                            }
                            
//                            if(this.canvas.canvasItem.grid)
//                            {
//                                this.canvas.canvasItem.grid.getEditForm().values[this.canvas.canvasItem.name]=vals;
//                                //this.canvas.canvasItem.grid.setEditValue(this.canvas.canvasItem.rowNum,this.canvas.canvasItem.colNum,vals);
//                            }else
//                            {
                                this.canvas.canvasItem.form.setValue(this.canvas.canvasItem.name,vals);
//                            }
                            uploader.start();
                        },

                        FileUploaded: function(up, file, info) {
                            // Called when file has finished uploading
                            //console.log('[FileUploaded] File:', file, "Info:", info);
                        },
             
                        ChunkUploaded: function(up, file, info) {
                            // Called when file chunk has finished uploading
                            //console.log('[ChunkUploaded] File:', file, "Info:", info);
                        },

                        UploadComplete: function(up, files) 
                        {
                            // Called when all files are either uploaded or failed
                            if(this.onUploadComplete)onUploadComplete(up,files);
                            //console.log('[UploadComplete]',up,files);
                        },

                        UploadProgress: function(up, file) 
                        {
                            //console.log('[UploadProgress]', up, file);
                            var vals;
//                            if(this.canvas.canvasItem.grid)
//                            {
//                                vals=this.canvas.canvasItem.grid.getEditForm().values[this.canvas.canvasItem.name];
//                                //vals=this.canvas.canvasItem.grid.getEditValue(file.grid.rowNum,file.grid.colNum);
//                                //vals=this.canvas.canvasItem.grid.getEditedRecord(file.grid.rowNum)[this.canvas.canvasItem.name];
//                                this.canvas.canvasItem.grid.validateCell(file.grid.rowNum,this.canvas.canvasItem.name);
//                            }else
//                            {
                                vals=this.canvas.canvasItem.form.getValue(this.canvas.canvasItem.name);
//                            }
                            
                            if(vals)
                            {
                                for(var i=0;i<vals.length;i++)
                                {
                                    var f=vals[i];
                                    if(f.id===file.id)
                                    {
                                        if(file.percent<100)
                                        {
                                            f.percent=file.percent;
                                        }else
                                        {
                                            delete f.percent;
                                        }
                                    }
                                }
//                                if(this.canvas.canvasItem.grid)
//                                {
//                                    //this.canvas.canvasItem.grid.setEditValue(file.grid.rowNum,file.grid.colNum,vals);
//                                }else
//                                {
                                    this.canvas.canvasItem.form.setValue(this.canvas.canvasItem.name,vals);
//                                }                            
                            }
                        },

                        Error: function(up, err) {
                            //console.log('[Error]:',err);
                            isc.say(err.message);
                                //document.getElementById(canvas.getContextID()+'_console').innerHTML += "\nError #" + err.code + ": " + err.message;
                        }
                }
        }); 
        canvas.uploader=uploader;
        uploader.canvas=canvas;
        uploader.init(); 
    },
        
});     



//*********** GridSelectItem ***********************************
isc.ClassFactory.defineClass("GridSelectItem", "CanvasItem");

isc.GridSelectItem.addProperties({
    height:"*", 
    width:"*",
    rowSpan:"*", 
    endRow:true, 
    startRow:true,
    
    // this is going to be an editable data item
    shouldSaveValue:true,
    
    // Implement 'createCanvas' to build a ListGrid from which the user may 
    // select items.
    createCanvas : function () 
    {
        this.dataSource = eng.createDataSource(this.dsDef,true,this);
        
        var grid1=isc.ListGrid.create({
            //dataSource:this.dataSource,
            fields:eng.mergeAndArray(eng.getDataSource(this.dsDef.dsName).getDataSourceScript().fields,this.fieldsSelect),
            width:"30%", height:this.height, 
            alternateRecordStyles:true,
//            canReorderRecords: true,
            canDragRecordsOut: true,
            canAcceptDroppedRecords: true,
            dragDataAction: "move",
            showAllRecords:true,
            initialCriteria: this.initialCriteria,
            //getCriteria: this.getPickListFilterCriteria,            
            autoFetchData:false,
            autoDraw:false,
            data:eng.getDataSource(this.dsDef.dsName).fetch({data:this.initialCriteria}).data,
            recordDrop : function (draggedRecords, targetRecord, targetIndex, sourceWidget) {
                // Call the super implementation of recordDrop() to update the order of rows in the ListGrid.
                this.Super("recordDrop", arguments);
                _this.storeData();
            }            
        });
        
        var grid2=isc.ListGrid.create({
            //dataSource:this.dataSource,
            fields:eng.mergeAndArray(eng.getDataSource(this.dsDef.dsName).getDataSourceScript().fields,this.fields),
            width:"60%", height:this.height, 
            alternateRecordStyles:true, 
            showAllRecords:true,
            emptyMessage: "No hay elementos seleccionados...",
            canDragRecordsOut: true,
            canAcceptDroppedRecords: true,
            canReorderRecords: true,
            dragDataAction: "move",
            autoFetchData:false,
            autoDraw:false,
            recordDrop : function (draggedRecords, targetRecord, targetIndex, sourceWidget) {
                // Call the super implementation of recordDrop() to update the order of rows in the ListGrid.
                this.Super("recordDrop", arguments);
                _this.storeData();
            }
        });
        
        var _this=this;
        
        _this.storeData=function()
        {
            var val=[];
            for(var x=0;x<grid2.data.length;x++)
            {
                val.push(grid2.data[x]._id);
            }
            _this.form.setValue(_this.name,val);
            console.log(val);
        }        
            
        var c=isc.HStack.create({membersMargin:10, width:this.width, height:this.height, autoDraw:false, members:[
            grid1,
            isc.VStack.create({width:"32", height:74, layoutAlign:"center", membersMargin:10, autoDraw:false, members:[
                isc.Img.create({src:eng.contextPath + "/platform/isomorphic/skins/Tahoe/images/DynamicForm/unstacked_spinner_plus.png", autoDraw:false, height:"25px",
                    click:function(){
                        grid2.transferSelectedData(grid1);
                        _this.dataValue=grid2.data;
                        _this.storeData();
                    }
                }),
                isc.Img.create({src:eng.contextPath + "/platform/isomorphic/skins/Tahoe/images/DynamicForm/unstacked_spinner_minus.png", autoDraw:false, height:"25px",
                    click:function(){
                        grid1.transferSelectedData(grid2);
                        _this.dataValue=grid2.data;
                        var val=[];
                        for(var x=0;x<grid2.data.length;x++)
                        {
                            val.push(grid2.data[x]._id);
                        }
                        _this.storeData();                  
                    }
                })
            ]}),
            grid2
        ]});
    
        this.gridSelect=grid1;
        this.grid=grid2;
    
        return c;
    },
   
//    getValue: function(){
//        return this.grid.data;
//    },
    
// implement showValue to update the ListGrid selection
    showValue : function (displayValue, dataValue) 
    {
        if (this.canvas == null) return;

        if (this.dataValue === dataValue)
            return; //comparar si cambio o no el contenido

        this.dataValue = dataValue;
        //recarga datos
        
        if(this.grid.data.length>0)
        {
            this.gridSelect.setData(eng.getDataSource(this.dsDef.dsName).fetch({data:this.initialCriteria}).data);  
        }
        if(dataValue)
        {
            this.grid.setData([]);
            this.gridSelect.deselectAllRecords();
            for(var i=0;i<dataValue.length;i++)
            {
                for(var j=0;j<this.gridSelect.data.length;j++)
                {
                    if(this.gridSelect.data[j]._id===dataValue[i])
                    {
                        this.gridSelect.selectRecord(j);
                    }
                }
            }
            this.grid.transferSelectedData(this.gridSelect);
            this.grid.deselectAllRecords();
        }
    }    
});

//*********** GridSelectItem ***********************************
isc.ClassFactory.defineClass("ListGridSelectItem", "CanvasItem");

isc.ListGridSelectItem.addProperties({
    height:"*", 
    width:"*",
    rowSpan:"*", 
    endRow:true, 
    startRow:true,
    
    // this is going to be an editable data item
    shouldSaveValue:true,
    
    // Implement 'createCanvas' to build a ListGrid from which the user may 
    // select items.
    createCanvas : function () 
    {
        this.dataSource = eng.createDataSource(this.dsDef,true,this);
        
        var grid=isc.ListGrid.create({
            name:this.name,
            width:this.width, 
            isShowing:false,            //al hacer showData ignorar selection
            height:this.height, 
            alternateRecordStyles:true,
            data: eng.getDataSource(this.dsDef.dsName).fetch({data:this.initialCriteria}).data,
            fields:this.fields,
            wrapCells: true,
            fixedRecordHeights: false,
            selectionAppearance:"checkbox",
            selectionType:this.multiple?"simple":"single",
            autoFetchData:false,
            dataSource:this.dataSource,            
            selectionChanged: function(record, state)
            {                
                if(this.isShowing)return;
                if(this.selectionType=="single")
                {
                    this.parentElement.setValue(this.name,state?record._id:null);
                }else
                {
                    var values=this.parentElement.getValue(this.name);
                    if(!(values instanceof Array))
                    {
                       values=[];
                    }
                    if(state)values.push(record._id);
                    else values.remove(record._id);
                    this.parentElement.setValue(this.name,values);
                }
                //console.log("selectionChanged", this,record,state,this.parentElement.getValue(this.name));
            }            
        });
        
        this.grid=grid;
        return grid;
    },
   
//    getValue: function(){
//        return this.grid.data;
//    },
    
// implement showValue to update the ListGrid selection
    showValue : function (displayValue, dataValue) 
    {
        if (this.canvas == null) return;
        
        if (this.dataValue === dataValue)
            return; //comparar si cambio o no el contenido

        this.dataValue = dataValue;
        //recarga datos
        
        this.canvas.isShowing=true;            
        if(dataValue)
        {
            //console.log("showValue",dataValue,this);
            if(dataValue instanceof Array)
            {
                //this.grid.deselectAllRecords();
                for(var i=0;i<dataValue.length;i++)
                {
                    for(var j=0;j<this.grid.data.length;j++)
                    {
                        if(this.grid.data[j]._id===dataValue[i])
                        {
                            this.grid.selectRecord(j);
                        }
                    }
                }                        
            }else
            {
                for(var j=0;j<this.grid.data.length;j++)
                {
                    if(this.grid.data[j]._id===dataValue)
                    {
                        this.grid.selectRecord(j);
                        break;
                    }
                }
           }
        }
        this.canvas.isShowing=false;
    }    
});

//*********** GoogleMapsItem ***********************************
isc.ClassFactory.defineClass("GoogleMapsItem", isc.CanvasItem);
isc.GoogleMapsItem.addProperties({
    shouldSaveValue:true,
    createCanvas: function() {
        this.gmapsID = this.ID+'_map';
        this.dataSource = eng.createDataSource(this.dsDef,true,this);
        var c = isc.VLayout.create({
            members:[
                isc.HTMLFlow.create({
                    width:"100%",
                    height:"*",
                    contents:'<input id="pac-input_'+this.ID+'" class="searchBoxGoogleMaps" style="width:50%;" type="text" placeholder="Buscar calle">'
                }),
                isc.HTMLFlow.create({
                    width:"100%",
                    height:"*",
                    contents:'<div class="boxedGoogleMaps" style="width:'+this.width+'px;height:'+this.height+'px;">\n\
                                <div id="'+this.gmapsID+'" style="width:99%;height:99%;"></div>\n\
                            </div>'
                }),
                isc.HTMLFlow.create({
                    width:"100%",
                    height:"*",
                    contents:'<div><input onclick="deleteMarkers();" type=button value="Borrar marcas"></div>'
                })
            ]
        });
        
        document.write('<script type="text/javascript" async defer>\n');
        document.write('var map,markers=[];');
        document.write('function initMap_'+this.ID+'(){var townDown={lat:19.432692,lng:-99.133434};map=new google.maps.Map(document.getElementById("'+this.gmapsID+'"),{zoom:12,center:townDown,mapTypeId:google.maps.MapTypeId.ROADMAP,styles:[{featureType:"poi",stylers:[{visibility:"off"}]},{featureType:"transit.station",stylers:[{visibility:"off"}]}],disableDoubleClickZoom:true,streetViewControl:false});map.addListener("dblclick",function(event){addMarker(event.latLng);'+this.ID+'.setCenter(this)});');
        document.write('var input=document.getElementById("pac-input_'+this.ID+'");var searchBox=new google.maps.places.SearchBox(input);map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);');
        document.write('map.addListener("bounds_changed",function(){searchBox.setBounds(map.getBounds());});');
        //document.write('var markers_=[];');
        document.write('searchBox.addListener("places_changed",function(){var places=searchBox.getPlaces();if(places.length==0){return;}');
        //document.write('markers_.forEach(function(marker){marker.setMap(null);});markers_=[];');
        document.write('var bounds=new google.maps.LatLngBounds();');
        document.write('places.forEach(function(place){');
        document.write('var icon={url:place.icon,size:new google.maps.Size(71,71),origin:new google.maps.Point(0,0),anchor:new google.maps.Point(17,34),scaledSize:new google.maps.Size(25,25)};');
        //document.write('markers_.push(new google.maps.Marker({map:map,icon:icon,title:place.name,position:place.geometry.location}));');
        document.write('if(place.geometry.viewport){bounds.union(place.geometry.viewport);}else{bounds.extend(place.geometry.location);}});');
        document.write('map.fitBounds(bounds);});');
        document.write('}\n');
        document.write('function addMarker(location){var marker=new google.maps.Marker({position:location,map: map});markers.push(marker);map.setCenter(location);}');
        document.write('function deleteMarkers(){for(var i=0;i<markers.length;i++){markers[i].setMap(null);}markers=[];}');
        //document.write('initMap_'+this.ID+'();');
        document.write('<\/script>');      
        
        if(this.mapping===1) {
            //document.write('<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAt_eGxLL6XMpo28l-kD-n23iW-LUiZmKs&libraries=places&callback=initMap_'+this.ID+'" async defer><\/script>');
            document.write('<script src="https://maps.googleapis.com/maps/api/js?key='+this.apiKey+'&libraries=places&callback=initMap_'+this.ID+'" async defer><\/script>');
        }
        return c;
    },
    setCenter: function(position) {
        this.form.setValue(this.name,'{"lat":'+position.center.lat()+',"lng":'+position.center.lng()+'}');
    },
    showValue: function(displayValue, dataValue, form, self) {
        if(self) {
            if(self.getValue() && self.getValue()!==null) {
                var pos = JSON.parse(self.getValue());
                var marker = new google.maps.Marker({position:pos, map:map});
                markers.push(marker);
                map.setCenter(pos);
            }
        }
    }
});

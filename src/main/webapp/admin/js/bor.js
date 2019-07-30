var grid = eng.createGrid({
    autoResize: true,
    resizeHeightMargin: 20,
    resizeWidthMargin: 15,
    canEdit: true,
    canAdd: false,
    canRemove: false,
    showFilter: true,
    ID: "segasig",
    createRecordComponent: function (record, colNum) {
        var fieldName = this.getFieldName(colNum);
        if (fieldName == "acciones") {
            var content = isc.HLayout.create({
                width: "100%", 
                height: 16, 
                margin: 0, 
                membersMargin: 15, 
                members: [
                    isc.HTMLFlow.create({
                        width: 16, 
                        contents: "<img style=\"cursor: pointer;\" width=\"16\" alt=\"Aceptar\" height=\"16\" src=\"/platform/isomorphic/skins/Tahoe/images/actions/accept.png\">", 
                        dynamicContents: true, 
                        showIf: function () {
                            return (record.estatus == "PENDIENTE" && record.usuario_recibe == eng.getUser()._id) || (eng.getUser().roles.contains("admin") && record.estatus == "PENDIENTE")
                        }, 
                        click: function () {
                            var req = eng.utils.getSynchData("/work/procAsig.jsp", JSON.stringify({rec: record._id, act: "accept"}), "POST");
                            isc.say(req.responseText);
                            grid.invalidateCache();
                            return false;
                        }
                    }), 
                    isc.HTMLFlow.create({
                        width: 16, 
                        contents: "<img style=\"cursor: pointer;\" width=\"16\" alt=\"Cancelar\" height=\"16\" src=\"/platform/isomorphic/skins/Tahoe/images/actions/cancel.png\">", 
                        dynamicContents: true, 
                        showIf: function () {
                            return record.estatus == "PENDIENTE"
                        }, 
                        click: function () {
                            var req = eng.utils.getSynchData("/work/procAsig.jsp", JSON.stringify({rec: record._id, act: "cancel"}), "POST");
                            isc.say(req.responseText);
                            grid.invalidateCache();
                            return false;
                        }
                    }), 
                    isc.HTMLFlow.create({
                        width: 16, 
                        contents: "<img style=\"cursor: pointer;\" width=\"16\" alt=\"Cancelar\" height=\"16\" src=\"/platform/isomorphic/skins/Tahoe/images/actions/print.png\">", 
                        dynamicContents: true, 
                        click: function () {
                            var id = record._id.substring(record._id.lastIndexOf(":") + 1);
                            window.open("/api/acuse/" + id, "acuse");
                            return false;
                        }
                    })
                ]
            });
            return content;
        } else {
            return null;
        }
    },
    showRecordComponents: true,
    showRecordComponentsByCell: true,

    recordDoubleClick: function (grid, record)
    {
        parent.loadContent("admin_content?pid=asignaciones&id=" + record["_id"], ".content-wrapper");
        return false;
    },

    addButtonClick: function (event)
    {
        parent.loadContent("admin_content?pid=asignaciones&id=", ".content-wrapper");
        return false;
    },

    fields: [{name: "folio"},
        {name: "fecha"},
        {name: "no_tarjetas"},
        {name: "usuario_entrega"},
        {name: "usuario_recibe"},
        {name: "entidad"},
        {name: "region_id"},
        {name: "comentarios"},
        {name: "fecha_aceptacion"},
        {name: "estatus"},
        {name: "acciones", canEdit: false, formatCellValue: function (value) {
                return " ";
            }}
    ]
}, "TarjetasAsignacion");
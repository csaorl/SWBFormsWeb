//Add yours validators here
eng.validators["curp"] = {type: "regexp", expression: "^([A-Z][AEIOUX][A-Z]{2}\\d{2}(?:0[1-9]|1[0-2])(?:0[1-9][12]\\d|3[01])[HM](?:AS|B[CS]|C[CLMSH]|D[FG]|G[TR]|HG|JC|M[CNS]|N[ETL]|OC|PL|Q[TR]|S[PLR]|T[CSL]|VZ|YN|ZS)[B-DF-HJ-NP-TV-Z]{3}[A-Z\\d])(\\d)$", errorMessage: "CURP invalida"};
eng.validators["curpSize"] = {type: "lengthRange", min: 18, max: 18, errorMessage: "El tamaño del CURP es de 18 caracteres"};
eng.validators["rfc"] = {type: "regexp", expression: "^([A-Z,Ñ,&]{3,4}([0-9]{2})(0[1-9]|1[0-2])(0[1-9]|1[0-9]|2[0-9]|3[0-1])[A-Z|\\d]{3})$", errorMessage: "RFC invalido"};
eng.validators["zipcode"] = {type: "regexp", expression: "^\\d{5}(-\\d{4})?$", errorMessage: "El codigo postal debe tener el formato ##### o #####-####."};
eng.validators["phone"] = {type: "mask", mask: "^\\s*(1?)\\s*\\(?\\s*(\\d{3})\\s*\\)?\\s*-?\\s*(\\d{3})\\s*-?\\s*(\\d{4})\\s*$", transformTo: "$1($2) $3 - $4", errorMessage: "El telefono debe tener el formato (###) ### - ####."};
eng.validators["phoneSize"] = {type: "lengthRange", min: 10, max: 13, errorMessage: "El teléfono debe tener al menos 10 numeros"};

//Add yours catalogs here
var states_mex = {
    1: "AGUASCALIENTES",
    2: "BAJA CALIFORNIA",
    3: "BAJA CALIFORNIA SUR",
    4: "CAMPECHE",
    5: "COAHUILA DE ZARAGOZA",
    6: "COLIMA",
    7: "CHIAPAS",
    8: "CHIHUAHUA",
    9: "CIUDAD DE MÉXICO",
    10: "DURANGO",
    11: "GUANAJUATO",
    12: "GUERRERO",
    13: "HIDALGO",
    14: "JALISCO",
    15: "MÉXICO",
    16: "MICHOACÁN DE OCAMPO",
    17: "MORELOS",
    18: "NAYARIT",
    19: "NUEVO LEÓN",
    20: "OAXACA",
    21: "PUEBLA",
    22: "QUERÉTARO",
    23: "QUINTANA ROO",
    24: "SAN LUIS POTOSÍ",
    25: "SINALOA",
    26: "SONORA",
    27: "TABASCO",
    28: "TAMAULIPAS",
    29: "TLAXCALA",
    30: "VERACRUZ DE IGNACIO DE LA LLAVE",
    31: "YUCATÁN",
    32: "ZACATECAS"
};
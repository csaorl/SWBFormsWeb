//******* Validations ************
eng.validators["unique"] = {type: "isUnique", errorMessage: "El valor del campo debe de ser único"};
eng.validators["id"] = {type: "regexp", expression: "\\w+", errorMessage: "Identificador no valido"};
eng.validators["email"] = {type: "regexp", expression: "^([a-zA-Z0-9_.\\-+])+@(([a-zA-Z0-9\\-])+\\.)+[a-zA-Z0-9]{2,4}$", errorMessage: "Correo electrónico invalido"};

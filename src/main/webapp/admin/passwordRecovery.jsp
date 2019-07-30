<%@page import="java.util.logging.Level"%>
<%@page import="java.util.logging.Logger"%>
<%@page import="java.io.IOException"%>
<%@page import="java.text.MessageFormat"%>
<%@page import="org.semanticwb.datamanager.utils.TokenGenerator"%>
<%@page import="org.semanticwb.datamanager.*"%><%!
    private static final Logger logger = Logger.getLogger("passwordRecovery");
%><%
    String contextPath = request.getContextPath();
    SWBScriptEngine eng=DataMgr.initPlatform("/WEB-INF/global.js",session);
    SWBDataSource ds=eng.getDataSource("User");

    if (request.getMethod().equals("POST")) 
    {
        String k=request.getParameter("k");            
        if(k!=null)
        {
            String userid=TokenGenerator.getUserIdFromToken(k);
            DataObject obj=ds.getObjectByNumId(userid);
            if(obj!=null && k.equals(obj.getString("recoveryToken")))
            {                
                obj.put("fullname", request.getParameter("fullname"));
                obj.put("password", request.getParameter("password"));
                obj.put("confirmed", "true");
                obj.put("active", "true");
                obj.put("recoveryToken",null);
                ds.updateObj(obj);
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Registration Page</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />


    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=contextPath%>/"><img src="/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Copntraseña</p>
             
        <p class="login-box-msg">Tu contraseña ha sido cambiada...</p>
        
        <a href="<%=contextPath%>/" class="text-center">Regresar a la pagina inicial</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
            }else
            {
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Recuperar Contraseña</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=contextPath%>/"><img src="<%=contextPath%>/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
        <p class="login-box-msg text-danger">Error al recuperar contraseña</p>
        <form action="" method="post" data-toggle="validator" role="form" id="regForm">
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email" data-remote="<%=contextPath%>/validator/existEmail" data-error="El correo electrónico no se encuentra registrado" required>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="row">
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Enviar</button>
            </div><!-- /.col -->
          </div>
        </form>        
        <a href="<%=contextPath%>/login" class="text-center">Ya tengo un usuario y contraseña</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%                  
            }                
        }else
        {
            String email = request.getParameter("email");
            if (email != null) {
                DataObject data = new DataObject();
                data.put("email", email);
                DataObject query = new DataObject();
                query.put("data", data);
                query = ds.fetch(query);
                DataList lista = query.getDataObject("response").getDataList("data");
                if (lista.size() == 1) 
                {
                    DataObject obj=lista.getDataObject(0);
                    String token=TokenGenerator.nextTokenByUserId(obj.getNumId());

                    StringBuilder content=new StringBuilder();
                    content.append("<!DOCTYPE html>");                    
                    content.append("<html>");
                    content.append("  <head>");   
                    content.append("    <meta charset=\"UTF-8\">");   
                    content.append("    <title>"+eng.getAppName()+" | Confirmación</title>");   
                    content.append("  </head>");   
                    content.append("  <body>");   
                    content.append("    <h1>"+eng.getAppName()+" Recuperar Contraseña</h1>");   
                    content.append("    <p>"+obj.getString("fullname")+", para recuperar su contraseña debe ingresar al siguiente link:</p>");   
                    content.append("    <p><a href=\"http://cloudino.io/passwordRecovery?k="+token+"\">Recuperar Contraseña</a></p>");   
                    content.append("    <p>O copia y pega el siguiente link en tu navegador: <br> http://cloudino.io/passwordRecovery?k={1}</p>");   
                    content.append("  </body>");   
                    content.append("</html>");   
                    
                    eng.getUtils().sendMail(email, obj.getString("fullname"), eng.getAppName()+" Recuperar Contraseña", content.toString(), "text/html", null);

                    logger.log(Level.FINE, "Password Recovery send mail to: {0}", email);
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Recuperar Contraseña</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=contextPath%>/"><img src="/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
             
        <p class="login-box-msg">Recibiras un correo electrónico con el vínculo para recuperar tu contraseña</p>
        
        <a href="<%=contextPath%>/" class="text-center">Regresar a la pagina de inicio</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
                } else {
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Recuperar Contraseña</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=contextPath%>/"><img src="<%=contextPath%>/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
        <p class="login-box-msg text-danger">El correo electrónico no esta registrado</p>
        <form action="" method="post" data-toggle="validator" role="form" id="regForm">
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email" data-remote="<%=contextPath%>/validator/existEmail" data-error="El correo electrónico no se encuentra registrado" required>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="row">
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Envia</button>
            </div><!-- /.col -->
          </div>
        </form>        
        <a href="<%=contextPath%>/login" class="text-center">Ya tengo un usuario y contraseña</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
                }
            }
        }
    } else {
        String k=request.getParameter("k");
        if(k!=null)
        {
            String userid=TokenGenerator.getUserIdFromToken(k);
            DataObject obj=ds.getObjectByNumId(userid);
            if(obj!=null && k.equals(obj.getString("recoveryToken")))
            {                
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Password Recovery Page</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=request.getContextPath()%>/"><img src="<%=contextPath%>/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
        <form action="" method="post" data-toggle="validator" role="form" id="regForm">
          <input type="hidden" name="k" value="<%=k%>">
          <div class="form-group has-feedback">
            <input type="text" name="fullname" class="form-control" placeholder="Full name" value="<%=obj.getString("fullname")%>" required>
            <span class="glyphicon glyphicons-user form-control-feedback"></span>
          </div>
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email" value="<%=obj.getString("email")%>" required disabled>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="form-group has-feedback">
            <input type="password" name="password" id="inputPassword" data-minlength="4" class="form-control" placeholder="Contraseña" data-error="Requires a minimal length of 4 characters" required>
            <span class="glyphicon glyphicon-lock form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="form-group has-feedback">
            <input type="password" name="password2" id="confirmPassword" data-match="#inputPassword" data-match-error="Both passwords don't match" class="form-control" placeholder="Retype password" required>
            <span class="glyphicon glyphicon-log-in form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="row">
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Enviar</button>
            </div><!-- /.col -->
          </div>
        </form>        
        <a href="<%=contextPath%>/login" class="text-center">Ya tengo un usuario y contraseña</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
            }else
            {
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Password Recovery Page</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=contextPath%>/"><img src="<%=contextPath%>/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
        <p class="login-box-msg text-danger">Error al recuperar contraseña</p>
        <form action="" method="post" data-toggle="validator" role="form" id="regForm">
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email" data-remote="<%=contextPath%>/validator/existEmail" data-error="El correo electrónico no se encuentra registrado" required>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="row">
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Enviar</button>
            </div><!-- /.col -->
          </div>
        </form>        
        <a href="<%=contextPath%>/login" class="text-center">Ya tengo un usuario y contraseña</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
            }
        }else
        {
%>
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Recuperar Contraseña</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
    <!-- Font Awesome Icons -->
    <link href="<%=contextPath%>/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="<%=contextPath%>/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="<%=contextPath%>/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
        <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body class="_register-page">
    <div class="register-box">
      <div class="register-logo">
        <a href="<%=request.getContextPath()%>/"><img src="<%=contextPath%>/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
      </div>

      <div class="register-box-body">
        <p class="login-box-msg">Recuperar Contraseña</p>
        <form action="" method="post" data-toggle="validator" role="form" id="regForm">
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email" data-remote="<%=contextPath%>/validator/existEmail" data-error="El correo electrónico no se encuentra registrado" required>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
            <div class="help-block with-errors"></div>
          </div>
          <div class="row">
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Enviar</button>
            </div><!-- /.col -->
          </div>
        </form>        
        <a href="<%=contextPath%>/login" class="text-center">Ya tengo un usuario y contraseña</a>
      </div><!-- /.form-box -->
    </div><!-- /.register-box -->

    <!-- jQuery 2.1.4 -->
    <script src="<%=contextPath%>/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="<%=contextPath%>/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>
    <!-- iCheck -->
    <script src="<%=contextPath%>/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
    <script src="<%=contextPath%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>
    <script>
      $(function () {
        $('input').iCheck({
          checkboxClass: 'icheckbox_square-blue',
          radioClass: 'iradio_square-blue',
          increaseArea: '20%' // optional
        });
      });
    </script>
  </body>
</html>
<%
        }
    }    
%>
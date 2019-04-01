<%-- 
    Document   : register
    Created on : 26-ago-2015, 17:54:48
    Author     : javiersolis
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="org.semanticwb.datamanager.*"%><%
    SWBScriptEngine eng = DataMgr.initPlatform("/admin/ds/base.js", session);
    String fullname = request.getParameter("fullname");
    String email = request.getParameter("email");
    String password = request.getParameter("password");
    String password2 = request.getParameter("password2");
    boolean producer = request.getParameter("producer")!=null;
    boolean agronomist = request.getParameter("agronomist")!=null;
    
    DataList roles=new DataList();
    roles.add("user");
    if(producer)roles.add("producer");
    if(agronomist)roles.add("agronomist");

    if (email != null && password != null) {
        if (password.equals(password2)) {
            SWBDataSource ds = eng.getDataSource("User");
            DataObject obj = new DataObject();
            obj.put("fullname", fullname);
            obj.put("email", email);
            obj.put("password", password);
            obj.put("roles", roles);
            ds.addObj(obj);
            //engine.close();
            
            session.setAttribute("_USER_", obj);            
            response.sendRedirect("/");
            return;
        }
    }
%><!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title><%=eng.getAppName()%> | Registration Page</title>
        <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
        <!-- Bootstrap 3.3.4 -->
        <link href="/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />    
        <!-- Font Awesome Icons -->
        <link href="/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
        <!-- Theme style -->
        <link href="/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
        <!-- iCheck -->
        <link href="/static/admin/plugins/iCheck/square/blue.css" rel="stylesheet" type="text/css" />
        <link href="/admin/css/login.css" rel="stylesheet" type="text/css" />
        
    </head>
    <body class="register-page">
        <div class="register-box">
            <div class="register-logo">
                <a href="/"><img src="/admin/img/logo.png" width="320" alt="<%=eng.getAppName()%>"></a>
            </div>

            <div class="register-box-body">
                <p class="login-box-msg">Registro de nuevo usuario</p>
                <form action="" method="post" data-toggle="validator" role="form">
                    <div class="form-group has-feedback">
                        <input type="text" name="fullname" class="form-control" placeholder="Nombre Completo" required/>
                        <span class="glyphicon glyphicons-user form-control-feedback"></span>
                    </div>
                    <div class="form-group has-feedback">
                        <input type="email" name="email" class="form-control" placeholder="Correo Electrónico" data-remote="/validator/email" data-error="El correo electrónico ya esta en uso" required/>
                        <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
                        <div class="help-block with-errors"></div>
                    </div>
                    <div class="form-group has-feedback">
                        <input type="password" name="password" id="inputPassword" class="form-control" placeholder="Contraseña" data-minlength="4" data-error="Se requiere mínimo 4 characters" required/>
                        <span class="glyphicon glyphicon-lock form-control-feedback"></span>
                        <div class="help-block with-errors"></div>
                    </div>
                    <div class="form-group has-feedback">
                        <input type="password" name="password2" data-match="#inputPassword" data-match-error="Las contraseñas no coinciden" class="form-control" placeholder="Confirmar contraseña" required/>
                        <span class="glyphicon glyphicon-log-in form-control-feedback"></span>
                        <div class="help-block with-errors"></div>
                    </div>            
                    <div class="checkbox icheck">
                    </div>                
                    <div class="row">
                        <div class="col-xs-8">    
                            <!--                
                                          <div class="checkbox icheck">
                                            <label>
                                              <input type="checkbox"> Estoy de acuerdo con los <a href="#">terminos</a>
                                            </label>
                                          </div>    
                            -->
                        </div><!-- /.col -->
                        <div class="col-xs-4">
                            <button type="submit" class="btn btn-primary btn-block btn-flat">Registrar</button>
                        </div><!-- /.col -->
                    </div>                    
                </form>        
                <!--
                        <div class="social-auth-links text-center">
                          <p>- OR -</p>
                          <a href="#" class="btn btn-block btn-social btn-facebook btn-flat"><i class="fa fa-facebook"></i> Sign up using Facebook</a>
                          <a href="#" class="btn btn-block btn-social btn-google-plus btn-flat"><i class="fa fa-google-plus"></i> Sign up using Google+</a>
                        </div>
                -->
                <a href="/login" class="text-center">Ya tengo un usuario y contraseña</a>
            </div><!-- /.form-box -->
        </div><!-- /.register-box -->

        <!-- jQuery 2.1.4 -->
        <script src="/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
        <!-- Bootstrap 3.3.2 JS -->
        <script src="/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>  
        <!-- iCheck -->
        <script src="<%=request.getContextPath()%>/static/plugins/validator/validator.min.js" type="text/javascript"></script>        
        <script src="/static/admin/plugins/iCheck/icheck.min.js" type="text/javascript"></script>
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
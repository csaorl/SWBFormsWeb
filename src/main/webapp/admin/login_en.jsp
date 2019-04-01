<%-- 
    Document   : index
    Created on : 15-abr-2017, 12:26:32
    Author     : javiersolis
--%>
<%@page import="org.semanticwb.datamanager.*"%><%
    SWBScriptEngine eng=DataMgr.initPlatform("/admin/ds/base.js",session);
    String email=request.getParameter("email");
    String password=request.getParameter("password");
    //System.out.println(email+" "+password);
    
    if(null!=request.getParameter("logout")){
        request.getSession().invalidate();
        response.sendRedirect(request.getContextPath() + "/");
    }
    if(email!=null && password!=null)
    {        
        SWBDataSource ds=eng.getDataSource("User");  
        DataObject r=new DataObject();
        DataObject data=new DataObject();
        r.put("data", data);
        data.put("email", email);
        data.put("password", password);
        DataObject ret=ds.fetch(r);
        //engine.close();
 
        DataList rdata=ret.getDataObject("response").getDataList("data");
        
        //System.out.println("ret"+ret);
        if(!rdata.isEmpty())
        {
            session.setAttribute("_USER_", rdata.get(0));
            String path=(String)request.getAttribute("servletPath");
            if(path==null || path.equals("/login"))path="/";
            response.sendRedirect(path);
            return;
        }
    }    
%>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%=eng.getAppName()%> | Log in</title>
    <meta content='width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no' name='viewport'>
    <!-- Bootstrap 3.3.4 -->
    <link href="/static/admin/bower_components/bootstrap/dist/css/bootstrap.min.css" rel="stylesheet" type="text/css" />    
    <!-- Font Awesome Icons -->
    <link href="/static/admin/bower_components/font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css" />
    <!-- Theme style -->
    <link href="/static/admin/dist/css/AdminLTE.min.css" rel="stylesheet" type="text/css" />
    <!-- iCheck -->
    <link href="/static/admin/plugins/iCheck/flat/blue.css" rel="stylesheet" type="text/css" />
  </head>
  <body class="login-page">
    <div class="login-box">
      <div class="login-logo">
        <a href="/"><b><%=eng.getAppName()%></b></a>
      </div><!-- /.login-logo -->
      <div class="login-box-body">
        <p class="login-box-msg">Sign in to start your session</p>
        <form action="" method="post" target="_top">
          <div class="form-group has-feedback">
            <input type="email" name="email" class="form-control" placeholder="Email"/>
            <span class="glyphicon glyphicon-envelope form-control-feedback"></span>
          </div>
          <div class="form-group has-feedback">
            <input type="password" name="password" class="form-control" placeholder="Password"/>
            <span class="glyphicon glyphicon-lock form-control-feedback"></span>
          </div>
          <div class="row">
            <div class="col-xs-8">    
              <div class="checkbox icheck">
                <label>
                  <input type="checkbox" name="Remember"> Remember Me
                </label>
              </div>                        
            </div><!-- /.col -->
            <div class="col-xs-4">
              <button type="submit" class="btn btn-primary btn-block btn-flat">Sign In</button>
            </div><!-- /.col -->
          </div>
        </form>
<!--
        <div class="social-auth-links text-center">
          <p>- OR -</p>
          <a href="#" class="btn btn-block btn-social btn-facebook btn-flat"><i class="fa fa-facebook"></i> Sign in using Facebook</a>
          <a href="#" class="btn btn-block btn-social btn-google-plus btn-flat"><i class="fa fa-google-plus"></i> Sign in using Google+</a>
        </div><!-- /.social-auth-links -->

        <a href="/passwordRecovery">I forgot my password</a><br>
        <a href="/register" class="text-center">Register a new membership</a>

      </div><!-- /.login-box-body -->
    </div><!-- /.login-box -->

    <!-- jQuery 2.1.4 -->
    <script src="/static/admin/bower_components/jquery/dist/jquery.min.js"></script>
    <!-- Bootstrap 3.3.2 JS -->
    <script src="/static/admin/bower_components/bootstrap/dist/js/bootstrap.min.js" type="text/javascript"></script>  
    <!-- iCheck -->
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
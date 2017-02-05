<%
var forEachIfExists = (function(arrayToIterate, handler){
	if(is.existy(arrayToIterate)){
		arrayToIterate.forEach(handler);
	}	
});

var writeServerExtensions = (function(service, bind){
	forEachIfExists(service.ServerExtensions, writeExtension);
});
var writeLocationsExtensions = (function(service, bind){
	forEachIfExists(bind.LocationExtensions, writeExtension);
});
var writeExtension = (function(extension){
%>		<%= extension %>;
<%	
});



%>#user  nobody;
worker_processes  <%= data.Workers.Count %>;
pid        /run/nginx.pid;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;


events {
    worker_connections  <%= data.Workers.Connections %>;
}

stream {
<%	Enumerable.from(data.Services).where("$.Enabled").toArray().forEach(function(service){ 
		var streamBinds = Enumerable.from(service.Binds).where(function(it){ return it.Type ==="stream" }).toArray();
		if(is.not.empty(streamBinds))
		{
%>
	#############################################################
	# Stream binds for Container <%= service.ContainerName %>
	#############################################################
<%	
		}
		streamBinds.forEach(function(bind){ 
			var bindPort = is.existy(bind.Port)?bind.Port : bind.HostPort;
			var containerPort = is.existy(bind.Port)?bind.Port : bind.ContainerPort;
%>	server { 
    	listen <%= bindPort %>; 
    	proxy_pass <%= service.ContainerName %>:<%= containerPort %>; 
<% writeServerExtensions(service, bind) %>
    }				
<%			
		}); 	
    }); 
%>	
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    client_max_body_size 50M;

    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

	#############################################################
    #
    #		HTTP
    #
    #############################################################


<%	Enumerable.from(data.Services).where("$.Enabled").toArray().forEach(function(service){ 
		var httpBinds = Enumerable.from(service.Binds).where(function(it){ return it.Type ==="http" }).toArray();
		if(is.not.empty(httpBinds))
		{
%>
	#############################################################
	# HTTP binds for Container <%= service.ContainerName %>
	#############################################################
<%	
		}
		httpBinds.forEach(function(bind){ 
			var bindPort = is.existy(bind.Port)?bind.Port : bind.HostPort;
			var containerPort = (is.existy(bind.Port)?bind.Port : bind.ContainerPort);
%>	server { 
    	listen <%= bindPort %>; 
		server_name  <%= bind.HostHeaderPattern %>;
<% writeServerExtensions(service, bind) %>
		location / {
    		proxy_pass http://<%= service.ContainerName %>:<%= containerPort %>; 
<% writeLocationsExtensions(service, bind) %>
			#proxy_set_header X-Real-IP $remote_addr;
			#add_header  Feedback $host;
		}
    }				
			
<%			
		}); 	
    }); 
%>	


	#############################################################
    #
    #		HTTPS
    #
    #############################################################

<%	Enumerable.from(data.Services).where("$.Enabled").toArray().forEach(function(service){ 
		var httpsBinds = Enumerable.from(service.Binds).where(function(it){ return it.Type ==="https" }).toArray();
		if(is.not.empty(httpsBinds))
		{
%>
	#############################################################
	# HTTPS binds for Container <%= service.ContainerName %>
	#############################################################
<%	
		}
		httpsBinds.forEach(function(bind){ 
			var bindPort = is.existy(bind.Port)?bind.Port : bind.HostPort;
			var containerPort = (is.existy(bind.Port)?bind.Port : bind.ContainerPort);
			var schema = (containerPort==80 ? "http" : "https");

%>	server { 
    	listen <%= bindPort %> ssl; 
		server_name  <%= bind.HostHeaderPattern %>;

		ssl_certificate         /cert/oragon.io/fullchain.pem;
    	ssl_certificate_key     /cert/oragon.io/privkey.pem;
		#ssl_dhparam             /cert/oragon.io/dhparam.pem;
        #ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        #ssl_prefer_server_ciphers on;
        #ssl_ciphers 'ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:AES:CAMELLIA:DES-CBC3-SHA:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!MD5:!PSK:!aECDH:!EDH-DSS-DES-CBC3-SHA:!EDH-RSA-DES-CBC3-SHA:!KRB5-DES-CBC3-SHA';
        #ssl_session_timeout 1d;		
        #ssl_session_cache shared:SSL:50m;
        #ssl_stapling on;
        #ssl_stapling_verify on;
        #add_header Strict-Transport-Security max-age=15768000;
		<% writeServerExtensions(service, bind) %>
		location / {			
    		proxy_pass <%= schema %>://<%= service.ContainerName %>:<%= containerPort %>; 
			<% writeLocationsExtensions(service, bind) %>
			
			#proxy_set_header X-Real-IP $remote_addr;
			#add_header  Feedback $host;
		}
		
    }				
<%		
		}); 	
    }); 
%>	


	#############################################################
    #
    #	DEFAULT	
    #
    #############################################################

    server {
        listen       80;
        server_name  xxx;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }
        location /nginx_status {
          stub_status;
          #access_log   off;
          #allow 1.1.1.1;
          #deny all;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

    }


}

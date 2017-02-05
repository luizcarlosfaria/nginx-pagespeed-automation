#!/bin/bash
docker rm -f <%= data.NginxContainerName %>

docker run \
-d \
--name <%= data.NginxContainerName %> \
--hostname <%= data.NginxContainerName %> \
--network=front \<% 
	var portsInUse = [];
Enumerable.from(data.Services).where("$.Enabled").toArray().forEach(function(service){ 
	var result = Enumerable.from(service.Binds).select(function(bind){
		var bindPort = is.existy(bind.Port)?bind.Port : bind.HostPort;
		var containerPort = is.existy(bind.Port)?bind.Port : bind.ContainerPort;
		var returnValue = "";
		if(Enumerable.from(portsInUse).any(function(it){ return it == bindPort}) == false)
		{
        	portsInUse.push(bindPort);
			return "-p " + bindPort + ":" + containerPort;
		}
		return returnValue;
	}).toArray().join(" "); 
%>
<%= result %> \<%
});
%>
-v /docker/EntryPoint/config:/etc/nginx/ \
-v /docker/EntryPoint/PageSpeed:/PageSpeed/ \
-v /docker/EntryPoint/logs:/var/log/nginx/ \
-v /docker/Certificados/:/cert/ \
luizcarlosfaria/nginx-pagespeed

sleep 2

docker ps -a --filter "name=<%= data.NginxContainerName %>"
docker logs <%= data.NginxContainerName %>

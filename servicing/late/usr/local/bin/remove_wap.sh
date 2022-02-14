#!/bin/sh
#. /home/engines/functions/params_to_env.sh
#params_to_env
# . /home/engines/functions/checks.sh

#required_values="fqdn protocol"
#check_required_values


	if test -f /etc/nginx/sites-enabled/${protocol}_${fqdn}.site
	 then
	 	rm /etc/nginx/sites-enabled/${protocol}_${fqdn}.site
	 	nginx -s reload
	else
		echo Success with Warning:config /etc/nginx/sites-enabled/${protocol}_${fqdn}.site not found
		exit 0
	fi

	 echo Success
	 

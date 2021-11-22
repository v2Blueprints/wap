#!/bin/sh

    if test $https = 'true'
    	then 
    		 proto="https"
    fi
   
    if test $http = 'true'
    	then 
    		if ! test -z $proto
    		  then
    		     proto="${proto}_"
    		  fi
        proto="${proto}http"
    fi  

 . /home/engines/functions/checks.sh

required_values="fqdn proto"
check_required_values


 
	if test -f /etc/nginx/sites-enabled/${proto}_${fqdn}.site
	 then
	 	rm /etc/nginx/sites-enabled/${proto}_${fqdn}.site	 
	 	nginx -s reload	
	else
		echo Success with Warning:config /etc/nginx/sites-enabled/${proto}_${fqdn}.site not found
		exit 0
	fi
	 
	 echo Success
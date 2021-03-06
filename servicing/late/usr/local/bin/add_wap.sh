#!/bin/sh

# . /usr/local/bin/checks.sh

#required_values="fqdn port protocol subdomain ip_address"
#check_required_values

#res=`nslookup ${subdomain}.engines.internal|grep -e "Address: *[0-9]" |awk '{print $2}'`
# `echo $res | grep -e "[0-9].*\.[0-9].*\.[0-9].*" >/dev/null`
# if test $? -ne 0
#  then
#	echo '{"status":"Error","message":"failed to find internal dns entry for '${subdomain}'.engines.internal"}'
#	exit 127
# fi

template="/usr/local/etc/templates/${protocol}_site.tmpl"

#resolv_ip_address=`nslookup control |grep -e "Address: *[0-9]" |awk '{print $2}'`

servers="server SERVER:PORT;"

if test $require_client_ssl = true
 then
  ENABLE_SSLCA=""
  ssl_verify=on
 else
  ssl_verify=off
  ENABLE_SSLCA='#'
fi

if test -z $ca_name
 then
   ca_file=system_CA.pem
   crl_file=system_CA_CRL.pem
 else
   ca_file=${ca_name}_CA.pem
   crl_file=${ca_name}_CA_CRL.pem
fi

cat $template | sed "/SERVERS/s//$servers/" \
| sed "/FQDN/s//$fqdn/g" \
| sed "/PORT/s//$port/g"\
| sed "/SERVER/s//$ip_address/g" \
| sed "/ENABLE_SSLCA/s//$ENABLE_SSLCA/" \
| sed "/CA_FILE/s//$ca_file/" \
| sed "/SSLVERIFY/s//$ssl_verify/"\
| sed "/CRL_FILE/s//$crl_file/" > /tmp/$fqdn.res
www_path=`echo $internal_dir  |sed "s/^\///" |sed "s/\/$//"`


rewrite=""
   if ! test -z $www_path
 then
    rewrite='rewrite \^\/'$www_path'\/\(\.\*\) \/'$www_path'\/\$1  break;\
        rewrite \^\/\(\.\*\) $fqdn\/'$www_path'\/\$1  break; '
fi
cat /tmp/$fqdn.res | sed "/FOLDER/s//$rewrite/" >  /tmp/$fqdn.path

domain=`echo $fqdn  | cut -f2- -d.`
if test "$protocol" = default
 then
    cp /tmp/site.name /etc/nginx/sites-enabled/default
 elif ! test "$protocol" = http
	 then
	 	if test -f /home/engines/etc/ssl/certs/${fqdn}.crt
	 		then
	 			cert_name=${fqdn}
	 		elif test -f /home/engines/etc/ssl/certs/${domain}.crt
	 		 then
	 		 	cert_name=$domain
	 		 elif test -f /home/engines/etc/ssl/certs/.${domain}.crt
	 		 then
	 		 	cert_name=.$domain
	        else
	        cert_name=wap
	     fi
		if test -f /etc/nginx/sites-enabled/http_https_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/http_https_${fqdn}.site
	     	fi
		if test -f /etc/nginx/sites-enabled/https_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/https_${fqdn}.site
	     	fi
	     	if test -f /etc/nginx/sites-enabled/http_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/http_${fqdn}.site
	     	fi
	    cat /tmp/${fqdn}.path  | sed "/CERTNAME/s//$cert_name/" > /etc/nginx/sites-enabled/${protocol}_${fqdn}.site
	 else  #protocol is http
		if test -f /etc/nginx/sites-enabled/http_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/http_${fqdn}.site
	     	fi
		if test -f /etc/nginx/sites-enabled/http_https_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/http_https_${fqdn}.site
	     	fi
		if test -f /etc/nginx/sites-enabled/https_${fqdn}.site
	     		then
	     			rm -f /etc/nginx/sites-enabled/https_${fqdn}.site
	     	fi
	 	cp /tmp/$fqdn.path /etc/nginx/sites-enabled/${protocol}_${fqdn}.site
fi

mkdir -p /tmp/last_run
cp 	/tmp/* /tmp/last_run

rm /tmp/*

	 if ! test -d /var/log/nginx/$fqdn/https/
	 	then
	 		mkdir -p /var/log/nginx/$fqdn/https/
	 	fi
 	if ! test -d /var/log/nginx/$fqdn/http/
 	then
 		mkdir -p /var/log/nginx/$fqdn/http/
 	fi
 nginx -s reload

echo '{"status":"Sucess"}'
exit 0

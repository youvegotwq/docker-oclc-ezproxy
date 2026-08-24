#!/bin/bash

cat << "EOF"

oooo                                 oooooooo               o8o
`888                                dP"""""""               `"'
 888 .oo.   oooo    ooo oo.ooooo.  d88888b.   oooo d8b     oooo   .ooooo.
 888P"Y88b   `88.  .8'   888' `88b     `Y88b  `888""8P     `888  d88' `88b
 888   888    `88..8'    888   888       ]88   888          888  888   888
 888   888     `888'     888   888 o.   .88P   888     .o.  888  888   888
o888o o888o     .8'      888bod8P' `8bd88P'   d888b    Y8P o888o `Y8bod8P'
            .o..P'       888
            `Y8P'       o888o

EOF

echo -e "Thanks for running this Docker container!"
echo -e ""
echo -e "----------------------------------------------------------------"
echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] The container hostname is $HOSTNAME."
if [[ $HOSTNAME != *.* ]]
then
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[33mYour HOSTNAME doesn't look like an FQDN.\e[39m"
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[33mPass 'docker -h <hostname>' or define the hostname in your docker-compose.yml.\e[39m"
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[91mEZproxy may not function correctly.\e[39m"
fi
echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] Generating missing files (if any) . . ."
/usr/local/ezproxy/ezproxy -d /usr/local/ezproxy/config -m > /dev/null
if [ -z "$EZPROXY_WSKEY" ]
then
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[33mEZPROXY_WSKEY variable is blank or null.\e[39m"
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] Checking for the existance of wskey.key . . ."
  if [ ! -f /usr/local/ezproxy/config/wskey.key ]
  then
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[33mwskey.key was not found in /usr/local/ezproxy/config.\e[39m"
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[91mEZproxy may not function correctly.\e[39m"
  else
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] \e[92mwskey.key was found in /usr/local/ezproxy/config.\e[39m"
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] EZproxy is presumed to be properly licensed."
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] This container does not check the validity of the WSKEY."
    echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] Please validate your EZproxy instance in the admin interface."
    fi
else
  echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] EZPROXY_WSKEY variable is set. Applying the WSKey . . ."
  /usr/local/ezproxy/ezproxy -k "$EZPROXY_WSKEY"
fi
echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] Starting EZproxy . . ."
echo -e "[$(date)] [\e[33mdocker-run.sh\e[39m] All logs below are from the EZproxy executable."
echo -e "----------------------------------------------------------------"
/usr/local/ezproxy/ezproxy -d /usr/local/ezproxy/config
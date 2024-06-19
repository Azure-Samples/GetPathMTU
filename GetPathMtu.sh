#!/bin/bash

ErrorMsg="Initial ping failed"

#################
#How to use this function
# examples
# sh GetPathMtu.sh -s <destination-ip> -l <initial-packet-size> -i <interface-name>
# sh GetPathMtu.sh -s  8.8.8.8 -l 1200 -i eth0
# note: 
# 1. -l (Initial packet size) and -s (destination IP-Address) are mandatory arguments
# 2. give initial packet size (1200 in above example) always a successfull ping packet-size
# 3. give correct interface name, code failes if interface name is wrong
#################

while getopts s:l:i: flag
do
    case "${flag}" in
        s) destinationIp=${OPTARG};;

	l) startSendBufferSize=${OPTARG};;

	i) interfaceName=${OPTARG};;
    esac
done

echo "destination: $destinationIp"
echo "startSendBufferSize: $startSendBufferSize"
echo "interfaceName: $interfaceName"

if [[ -z "$interfaceName" ]]; then
    initialPingOutput=$(ping -4 -M do -c 1 -s $startSendBufferSize $destinationIp)
else
    initialPingOutput=$(ping -4 -M do -c 1 -s $startSendBufferSize $destinationIp -I $interfaceName)
fi

if [[ $initialPingOutput = *'0 received'* ]]; then
    echo $ErrorMsg
    echo "Initial ping should be successfull, check Destination-IP or lower initial size"
    exit 1
fi

sendBufferSize=0
tempPassedBufferSize=$startSendBufferSize
echo -n "Test started ...."

while [ $tempPassedBufferSize -ne $sendBufferSize ]; do

    sendBufferSize=$tempPassedBufferSize

    counter=0
    tempSendBufferSize=$sendBufferSize
    successfullBufferSize=$sendBufferSize
    while [ true ]; do
	
        if [[ -z "$interfaceName" ]]; then
            ping -4 -M do -c 1 -s $tempSendBufferSize $destinationIp &> /dev/null
        else
            ping -4 -M do -c 1 -s $tempSendBufferSize $destinationIp -I $interfaceName &> /dev/null
	fi 
            
        if [ $? -eq 1 ]
        then
           break
        fi
        echo -n "...."
        successfullBufferSize=$tempSendBufferSize
        tempSendBufferSize=$(($tempSendBufferSize + 2**$counter))
        counter=$(($counter + 1))
    done
    tempPassedBufferSize=$successfullBufferSize
done
finalMtuInTopology=$(($sendBufferSize + 28))          
echo ""
echo  "$finalMtuInTopology"

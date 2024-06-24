#!/bin/bash


#################
# 
# This function will find the optimal MTU between source and destination
# 
# How to use this funciton
# This script can be used with or without flags, see examples for more clarity in usage
# both options (using with and without flags) are mutual exclusive 
# This function takes the following parameters
# Destination IPv4-Address : This is mandatory parameter, we can either use the parameter
#                            with a flat -s or without a flag
# Initial Buffer size      : This optional parameter, the default value is 1200bytes
# Interface Name           : This optional parameter, not using the inteface parameter
#                            will use the default interface for communication
# 
# examples
# sh GetPathMtu.sh  10.1.0.4  
# sh GetPathMtu.sh  -r 10.1.0.4 -l 2100 -i eth0
# sh GetPathMtu.sh  -r 10.1.0.4 -l 1000
# sh GetPathMtu.sh  -r <destination-ip> -l <initial-packet-size> -i <interface-name>
# sh GetPathMtu.sh  -r  8.8.8.8 -l 1200 -i eth0
#################

while getopts r:l:i: flag
do
    case "${flag}" in
        r) destinationIp=${OPTARG};;

	l) startSendBufferSize=${OPTARG};;

        i) interfaceName=${OPTARG};;

	?) echo "Error: Invalid option was specified -$OPTARG"
	   exit 1;;
    esac
done

if [ -z "$destinationIp" ]; then
    destinationIp=$1;
fi

if [ -z "$startSendBufferSize" ]; then
    startSendBufferSize=1200;
fi

echo "destination: $destinationIp"
echo "startSendBufferSize: $startSendBufferSize"

if [ -z "$interfaceName" ]
then
    echo "interfaceName: Default interface"
    initialPingOutput=$(ping -4 -M do -c 1 -s $startSendBufferSize $destinationIp)
else
    echo "interfaceName: $interfaceName"
    initialPingOutput=$(ping -4 -M do -c 1 -s $startSendBufferSize $destinationIp -I $interfaceName)
fi

if [ $? -ne 0 ]
then
    echo "Exiting the code, error occured in intial ping"
    exit 1
fi

if [[ $initialPingOutput == *"0 received"* ]]; then
    echo "Initial ping failed"
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
	
        if [ -z "$interfaceName" ]
	then
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

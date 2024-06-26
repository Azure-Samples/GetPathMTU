---
name: GetPathMTU - Path MTU Discovery Sample Script
description: Sample script to test maximum MTU between source and destination. 
languages:
- bash
products:
- azure
- azure-virtual-network
page_type: sample
urlFragment: GetPathMTU
---
<!-- YAML front-matter schema: https://review.learn.microsoft.com/en-us/help/contribute/samples/process/onboarding?branch=main#supported-metadata-fields-for-readmemd -->





# Project Name

GetPathMTU is a bash script that provides the user a way to test the maximum supported MTU between the source where code is executed and the destination provided.

## Getting Started

### Installation

Clone the repository or download `GetPathMTU.sh` directly, then run the script.

### Quickstart

1. Clone the Repository

    `git clone https://github.com/Azure-Samples/GetPathMTU.git`

2. Navigate into the folder containing the script

    `cd GetPathMTU`

3. Run the script

    `./GetPathMTU.sh <Destination IP>`

### Parameters

Destination IPv4-Address : This is mandatory parameter, we can either use the parameter with a flat -s or without a flag
Initial Buffer size      : This optional parameter, the default value is 1200 bytes
Interface Name           : This optional parameter, not using the inteface parameter will use the default interface for communication

#### Examples

```bash
./GetPathMtu.sh  10.1.0.4  
./GetPathMtu.sh  -r 10.1.0.4 -l 2100 -i eth0
./GetPathMtu.sh  -r 10.1.0.4 -l 1000
./GetPathMtu.sh  -r <destination-ip> -l <initial-packet-size> -i <interface-name>
./GetPathMtu.sh  -r  10.1.0.4 -l 1200 -i eth0
```

## Demo

Sample results:

```bash
$ ./GetPathMtu.sh 10.1.0.4
destination: 10.1.0.4
startSendBufferSize: 1200
interfaceName: Default interface
Test started .....................................
1492
```

In this instance 1492 is the maximum MTU size (IP Header + Payload) allowable from the source running the script to the destination.

## Resources

The [Powershell Test-Connection](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/test-connection?view=powershell-7.4) command provides similiar capability with -MtuSize parameter.

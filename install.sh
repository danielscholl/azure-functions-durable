#!/usr/bin/env bash
#
#  Purpose: Initialize the template load for testing purposes
#  Usage:
#    init.sh <prefix> <resourcegroup> <locations>


###############################
## ARGUMENT INPUT            ##
###############################
usage() { echo "Usage: init.sh <prefix> <resourcegroup> <location>" 1>&2; exit 1; }


if [ ! -z $1 ]; then PREFIX=$1; fi
if [ -z $PREFIX ]; then
  tput setaf 1; echo 'ERROR: PREFIX not provided' ; tput sgr0
  usage;
fi
tput setaf 1; echo "PREFIX: ${PREFIX}" ; tput sgr0

if [ ! -z $2 ]; then RESOURCE_GROUP=$2; fi
if [ -z $RESOURCE_GROUP ]; then
  RESOURCE_GROUP="durablefunctions"
  tput setaf 1; echo "RESOURCE_GROUP: ${RESOURCE_GROUP}" ; tput sgr0
fi

if [ ! -z $3 ]; then LOCATION=$3; fi
if [ -z $LOCATION ]; then
  LOCATION="southcentralus"
  tput setaf 1; echo "LOCATION: ${LOCATION}" ; tput sgr0
fi

###############################
## FUNCTIONS                 ##
###############################
function CreateResourceGroup() {
  # Required Argument $1 = RESOURCE_GROUP
  # Required Argument $2 = LOCATION

  if [ -z $1 ]; then
    tput setaf 1; echo 'ERROR: Argument $1 (RESOURCE_GROUP) not received'; tput sgr0
    exit 1;
  fi
  if [ -z $2 ]; then
    tput setaf 1; echo 'ERROR: Argument $2 (LOCATION) not received'; tput sgr0
    exit 1;
  fi

  local _result=$(az group show --name $1)
  if [ "$_result"  == "" ]
    then
      OUTPUT=$(az group create --name $1 \
        --location $2 \
        -ojsonc)
    else
      tput setaf 3;  echo "Resource Group $1 already exists."; tput sgr0
    fi
}

###############################
## Azure Intialize           ##
###############################


##############################
## Deploy Template          ##
##############################

tput setaf 2; echo "Retrieving Resource Group..." ; tput sgr0
CreateResourceGroup $RESOURCE_GROUP $LOCATION

tput setaf 2; echo "Deploying ARM Template..." ; tput sgr0
if [ -d ./scripts ]; then BASE_DIR=$PWD; else BASE_DIR=$(dirname $PWD); fi
az group deployment create \
  --template-file $BASE_DIR/templates/azuredeploy.json \
  --parameters $BASE_DIR/templates/azuredeploy.parameters.json \
  --parameters Prefix=$PREFIX \
  --resource-group $RESOURCE_GROUP

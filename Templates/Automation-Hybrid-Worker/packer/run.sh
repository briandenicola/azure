#!/bin/bash 

#export BUILD_VERSION=`date +"%U"`
export BUILD_VERSION=49

packer init ./azure_linux.pkr.hcl
packer build -var "build_version=${BUILD_VERSION}" .
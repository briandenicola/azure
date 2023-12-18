#!/bin/bash 

export BUILD_VERSION=`date +"%U"`

packer init ./azure_linux.pkr.hcl
packer build -var "build_version=${BUILD_VERSION}" .
#!/bin/bash 

mvn clean
mvn compile clean
mvn exec:java -Dexec.mainClass="JedisEntraIdManagedIdentityDemo"

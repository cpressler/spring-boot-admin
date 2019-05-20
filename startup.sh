#!/usr/bin/env bash
export SV_SPRING_CLOUD_CONFIG=`pwd`
export LOGDIR=`pwd`
mvn clean package -DskipTests
java -jar target/spring-boot-admin-1.0.0-SNAPSHOTgit
-boot.jar
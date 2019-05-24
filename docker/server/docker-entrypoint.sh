#!/bin/bash
set -e

echo "Start entrypoint"

cd /opt/services/spring-boot-admin/
# this will force it to run forever in background

#java -Dspring.profiles.active=container -jar  spring-react-qatest-boot.jar

java  -jar  spring-boot-admin-boot.jar

echo "DONE entrypoint"

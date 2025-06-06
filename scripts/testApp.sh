#!/bin/bash
set -euxo pipefail
./mvnw -version

##############################################################################
##
##  GH actions CI test script
##
##############################################################################

# LMP 3.0+ goals are listed here: https://github.com/OpenLiberty/ci.maven#goals
export HOSTNAME=localhost

## Rebuild the application
./mvnw -ntp -Dhttp.keepAlive=false \
    -Dmaven.wagon.http.pool=false \
    -Dmaven.wagon.httpconnectionManager.ttlSeconds=120 \
    -q clean package
./mvnw -ntp -pl system liberty:create 
./mvnw -ntp -pl system liberty:install-feature 
./mvnw -ntp -pl system liberty:deploy

./mvnw -ntp -pl inventory liberty:create 
./mvnw -ntp -pl inventory liberty:install-feature 
./mvnw -ntp -pl inventory liberty:deploy

## Run the tests
./mvnw -ntp -pl system liberty:start
./mvnw -ntp -pl inventory liberty:start
./mvnw -ntp verify -Dsystem.ip=localhost:9080 -Dinventory.ip=localhost:8080 
./mvnw -ntp -pl system liberty:stop 
./mvnw -ntp -pl inventory liberty:stop

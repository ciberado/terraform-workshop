#!/bin/sh

sudo apt update
sudo apt install openjdk-8-jre-headless -y
wget https://github.com/ciberado/pokemon/releases/download/stress/pokemon-0.0.4-SNAPSHOT.jar
java -jar pokemon-0.0.4-SNAPSHOT.jar
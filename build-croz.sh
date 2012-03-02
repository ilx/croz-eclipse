#!/usr/bin/env sh

# disable p2 mirrors in the remote repo (otherwise we might end up using some eclipse.org p2 repo)
export MAVEN_OPTS="-Declipse.p2.mirrors=false"
export INSTALL_DIR="/tmp/eclipse-3.7.2"

# debug maven:
#export MAVEN_OPTS="-Declipse.p2.mirrors=false -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"
# Maven properties can be overwritten. Otherwise default ones (from settings file) will be used.
# Here's an example how to override default value of eclipse.mirror.url property:
#mvn -s settings.croz.xml -Pcroz -Dbuild.destination=$INSTALL_DIR -Declipse.mirror.url="http://deploy.lan.croz.net/eclipseMirror" compile
mvn -s settings.croz.xml -Pcroz -Dbuild.destination=$INSTALL_DIR compile


#!/usr/bin/env bash

# disable p2 mirrors in the remote repo (otherwise we might end up using some eclipse.org p2 repo)
export MAVEN_OPTS="-Declipse.p2.mirrors=false"

# debug maven:
#export MAVEN_OPTS="-Declipse.p2.mirrors=false -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"
# Maven properties can be overwritten. Otherwise default ones (from settings file) will be used.
# Here's an example how to override default value of eclipse.mirror.url property:

# install just eclipse with m2e:
#mvn -s settings.croz.xml -Pcroz -Dbuild.destination=$INSTALL_DIR -Declipse.mirror.url="http://deploy.lan.croz.net/eclipseMirror" compile

#define default values
EFLAG=JEE
VERBOSITY=0

function usage(){
USAGE=$(
cat <<EOF
	-h 		this help
	-d 		install destination directory
	-e [JDT|JEE|OTDT] 	installation environment (JEE,OT)
	-v		verbosity
EOF
)
	echo $USAGE
}

while getopts "d:hev" OPTION; do
	case "$OPTION" in
		d)
			DFLAG="$OPTARG"
			INSTALL_DIR=$DFLAG
			;;
		e)
			EFLAG="$OPTARG"
			;;
		v)
			VERBOSE=1
			;;
		h)
			usage
			;;
		*)
			usage
			;;
	esac
done

function validate() {
	if [ -z "$DFLAG" ]; then
		echo "Destination must be defined"
		BREAK=1
	fi

	if [ -n "$BREAK" ]; then 
		usage
		exit
	fi
}


function install() {
	case "$EFLAG" in
	JEE)
		PLUGINS="-Pcroz -Dajdt -Danyedit -Dcheckstyle -Declemma -Dmoreunit -Dsts -Dsubclipse"
		;;
	OTDT)
		# currently OTDT doesn;t play well with AJDT (required by STS)
		PLUGINS="-Pcroz -Danyedit -Dcheckstyle -Declemma -Dmoreunit -Dotdt -Dsubclipse"
		;;
	JDT)
		PLUGINS="-Pcroz"
		;;
	*)
		usage
		exit
		;;
	esac
	echo mvn -s settings.croz.xml $PLUGINS -Dbuild.destination=$INSTALL_DIR -Dbuild.p2.bundlepool=$INSTALL_DIR/../p2 compile
	mvn -s settings.croz.xml $PLUGINS -Dbuild.destination=$INSTALL_DIR -Dbuild.p2.bundlepool=$INSTALL_DIR/../p2 compile
}

validate
install



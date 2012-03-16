#!/usr/bin/env bash

# disable p2 mirrors in the remote repo (otherwise we might end up using some eclipse.org p2 repo)
export MAVEN_OPTS="-Declipse.p2.mirrors=false"

# debug maven:
#export MAVEN_OPTS="-Declipse.p2.mirrors=false -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=8000"
# install just eclipse with m2e:
#mvn -s settings.croz.xml -Pcroz -Dbuild.destination=$INSTALL_DIR -Declipse.mirror.url="http://deploy.lan.croz.net/eclipseMirror" compile

#define default values
EFLAG=JEE
VERBOSITY=0
SETTINGS=settings.croz.xml
PROFILE=-Pcroz

function usage(){
cat <<EOF
	-h 			this help
	-d 			install destination directory
	-e [JDT|JEE|OTDT]  	installation environment (JEE,OT)
	-l                 	use local settings 
	-p 			use bundle pool
	-r			use roaming profile (allows you to copy installation to some other dir)
	-v			verbosity

Examples:

Install JEE version of eclipse using CROZ repositories, not using roaming profile, bundle pool same as destination
	> ./build-croz.sh -v -e JEE -d /opt/java/eclipse/e37/scalaide

Install JDT version of eclipse using local repositories with roaming profile, bundle pool same as destination
	> ./build-croz.sh -v -l -e JDT -d /opt/java/eclipse/e37/test -r 
EOF
	exit
}

while getopts "d:e:hlprv" OPTION; do
	case "$OPTION" in
		d)
			DFLAG="$OPTARG"
			INSTALL_DIR=$DFLAG
			;;
		e)
			EFLAG="$OPTARG"
			;;
		h)
			usage
			;;
		l)      
			#OPTS="-o -X"
			PROFILE=-Plocal
			SETTINGS=settings.local.xml
			;;
		v)
			VERBOSE=1
			;;
		p)
			PFLAG=1
			;;
		r)
			RFLAG=1
			;;
		*)
			usage
			;;
	esac
done

echo "$EFLAG"

function validate() {
	echo "BEGIN: validate"
	if [ -z "$DFLAG" ]; then
		echo "Destination must be defined"
		BREAK=1
	fi
	if [ -z "$EFLAG" ]; then
		echo "Environment must be defined"
		BREAK=1
	fi

	if [ -n "$BREAK" ]; then 
		usage
		exit
	fi
	echo "END: validate"
}


function install() {
	echo "BEGIN: install"
	case "$EFLAG" in
	JEE)
		PLUGINS="-Dajdt -Danyedit -Dcheckstyle -Declemma -Dmoreunit -Dsts -Dsubclipse"
		;;
	OTDT)
		# currently OTDT doesn;t play well with AJDT (required by STS)
		PLUGINS="-Danyedit -Dcheckstyle -Declemma -Dmoreunit -Dotdt -Dsubclipse"
		;;
	JDT)
		PLUGINS=""
		;;
	*)
		usage
		exit
		;;
	esac
	#BUNDLE_POOL="-Dbuild.p2.bundlepool=$INSTALL_DIR"
	BUNDLE_POOL="-Dbuild.p2.bundlepool=$INSTALL_DIR"
	ROAMING="-Dbuild.p2.roaming=''"
	if [ -n "$PFLAG" ]; then BUNDLE_POOL="-Dbuild.p2.bundlepool=$INSTALL_DIR/../p2" ;fi
	if [ -n "$RFLAG" ]; then ROAMING="-Dbuild.p2.roaming='-roaming'" ; fi
	echo mvn $OPTS $PROFILE -s $SETTINGS $PLUGINS -Dbuild.destination=$INSTALL_DIR $ROAMING $BUNDLE_POOL compile
	mvn $OPTS $PROFILE -s $SETTINGS $PLUGINS -Dbuild.destination=$INSTALL_DIR $ROAMING $BUNDLE_POOL compile
}

validate
install



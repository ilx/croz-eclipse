set MAVEN_OPTS="-Declipse.p2.mirrors=false"
set INSTALL_DIR="C:/tmp/eclipse-3.7.2"
mvn -s settings.croz.xml -Pcroz -Dajdt -Danyedit -Declemma -Dmoreunit -Dsts -Dsubclipse -Dbuild.destination=%INSTALL_DIR% compile


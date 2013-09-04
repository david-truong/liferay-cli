#!/bin/sh

PRG="$0"

while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '.*-> \(.*\)$'`
    if expr "$link" : '/.*' > /dev/null; then
        PRG="$link"
    else
        PRG=`dirname "$PRG"`/"$link"
    fi
done
RAY_HOME=`dirname "$PRG"`

# Absolute path
RAY_HOME=`cd "$RAY_HOME/.." ; pwd`

# echo Resolved RAY_HOME: $RAY_HOME
# echo "JAVA_HOME $JAVA_HOME"

cygwin=false;
case "`uname`" in
    CYGWIN*)
        cygwin=true
        ;;
esac

# Build a classpath containing our two magical startup JARs (we look for " /" as per ray-905)
RAY_CP=`echo "$RAY_HOME"/bin/*.jar | sed 's/ \//:\//g'`
# echo RAY_CP: $RAY_CP

# Store file locations in variables to facilitate Cygwin conversion if needed

RAY_OSGI_FRAMEWORK_STORAGE="$RAY_HOME/cache"
# echo "RAY_OSGI_FRAMEWORK_STORAGE: $RAY_OSGI_FRAMEWORK_STORAGE"

RAY_AUTO_DEPLOY_DIRECTORY="$RAY_HOME/bundle"
# echo "RAY_AUTO_DEPLOY_DIRECTORY: $RAY_AUTO_DEPLOY_DIRECTORY"

RAY_CONFIG_FILE_PROPERTIES="$RAY_HOME/conf/config.properties"
# echo "RAY_CONFIG_FILE_PROPERTIES: $RAY_CONFIG_FILE_PROPERTIES"

cygwin=false;
case "`uname`" in
    CYGWIN*)
        cygwin=true
        ;;
esac

if [ "$cygwin" = "true" ]; then
    export RAY_HOME=`cygpath -wp "$RAY_HOME"`
    export RAY_CP=`cygpath -wp "$RAY_CP"`
    export RAY_OSGI_FRAMEWORK_STORAGE=`cygpath -wp "$RAY_OSGI_FRAMEWORK_STORAGE"`
    export RAY_AUTO_DEPLOY_DIRECTORY=`cygpath -wp "$RAY_AUTO_DEPLOY_DIRECTORY"`
    export RAY_CONFIG_FILE_PROPERTIES=`cygpath -wp "$RAY_CONFIG_FILE_PROPERTIES"`
    # echo "Modified RAY_HOME: $RAY_HOME"
    # echo "Modified RAY_CP: $RAY_CP"
    # echo "Modified RAY_OSGI_FRAMEWORK_STORAGE: $RAY_OSGI_FRAMEWORK_STORAGE"
    # echo "Modified RAY_AUTO_DEPLOY_DIRECTORY: $RAY_AUTO_DEPLOY_DIRECTORY"
    # echo "Modified RAY_CONFIG_FILE_PROPERTIES: $RAY_CONFIG_FILE_PROPERTIES"
fi

# make sure to disable the flash message feature for the default OSX terminal, we recommend to use a ANSI compliant terminal such as iTerm if flash message support is desired
APPLE_TERMINAL=false;
if [ "$TERM_PROGRAM" = "Apple_Terminal" ]; then
	APPLE_TERMINAL=true
fi

ANSI="-Dray.console.ansi=true"
# Hop, hop, hop...
java -Dis.apple.terminal=$APPLE_TERMINAL $RAY_OPTS $ANSI -Dray.args="$*" -DdevelopmentMode=false -Dorg.osgi.framework.storage="$RAY_OSGI_FRAMEWORK_STORAGE" -Dfelix.auto.deploy.dir="$RAY_AUTO_DEPLOY_DIRECTORY" -Dfelix.config.properties="file:$RAY_CONFIG_FILE_PROPERTIES" -cp "$RAY_CP" com.liferay.cli.bootstrap.Main
EXITED=$?
# echo ray exited with code $EXITED

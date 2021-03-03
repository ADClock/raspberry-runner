#!/bin/bash

# Config
GITHUB_REPO="adclock/server"
JAR_FILE="server.jar"
DELAY=5 # seconds


# Functions
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

# Main
while :
do
    # Checkout latest release
    LATEST_RELEASE=$(get_latest_release $GITHUB_REPO)
    echo "Latest release of $GITHUB_REPO is $LATEST_RELEASE" 

    if [ ! -d "./$LATEST_RELEASE" ]; then
      echo "New release $LATEST_RELEASE found. Creating subfolder ..."
      mkdir "./$LATEST_RELEASE"
    fi 

    cd "./$LATEST_RELEASE" # enter release folder

    if [ ! -f "./$JAR_FILE" ]; then
      echo "Jar not found. Download $JAR_FILE @ $LATEST_RELEASE from GitHub ..."
      curl --silent -O -J -L "https://github.com/$GITHUB_REPO/releases/download/$LATEST_RELEASE/$JAR_FILE"
    fi 

    # Run JAR_FILE
    java -jar $JAR_FILE
    rc=$?
    echo "$JAR_FILE returned $rc."

    if [ $rc -eq 1 ]; then
        echo "An error occurred. Waiting $DELAY seconds ..."
        sleep $DELAY # seconds
    fi
    
    cd .. # leave release folder
    echo "Try to restart $JAR_FILE ... "
done

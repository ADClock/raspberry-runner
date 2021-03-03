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
    # (1) Check if release version was passed as parameter
    if [ -z $1 ]; then
        RELEASE=""
    else 
        RELEASE="$1"
        echo "Using first parameter '$1' as release."
    fi
    
    # (2) if not, check against github
    if [ -z $RELEASE ]; then
        # Checkout latest release
        LATEST_RELEASE=$(get_latest_release $GITHUB_REPO)
        if [ -z $LATEST_RELEASE ]; then
            echo "Release check against github api failed. (Maybe API rate limit exceeded?)"
        else
            RELEASE=$LATEST_RELEASE
            echo "Latest release of $GITHUB_REPO is $RELEASE."
        fi
    fi
    
    # (3) if github check fails, take latest local version
    if [ -z $RELEASE ]; then
        LOCAL_RELEASE=$(ls -td */$JAR_FILE | head -n 1 | cut -d'/' -f1)
        
        if [ -z $LOCAL_RELEASE ]; then
            echo "No local release folder found. Can't retrive release version. Exiting ..."
            exit 1
        else
            RELEASE=$LOCAL_RELEASE
            echo "Using latest local release $RELEASE."
        fi
        
    fi
     

    echo "Using release $RELEASE" 
    if [ ! -d "./$RELEASE" ]; then
      echo "No subfolder with name $RELEASE found. Creating new one ..."
      mkdir "./$RELEASE"
    fi 

    cd "./$RELEASE" # enter release folder

    if [ ! -f "./$JAR_FILE" ]; then
      echo "$JAR_FILE not found. Downloading from GitHub $GITHUB_REPO @ $RELEASE ..."
      curl --silent -O -J -L "https://github.com/$GITHUB_REPO/releases/download/$RELEASE/$JAR_FILE"
      
      # TODO remove release folder, if downloaded jar file was not found.
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

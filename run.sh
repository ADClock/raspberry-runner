# Config
GITHUB_REPO="adclock/server"
JAR_FILE="server.jar"
DELAY=5


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
    echo "Latest release is $LATEST_RELEASE" 

    if [ ! -d "./$LATEST_RELEASE" ]; then
      echo "New release $LATEST_RELEASE. Creating subfolder ..."
      mkdir "./$LATEST_RELEASE"
    fi 

    cd "./$LATEST_RELEASE"

    if [ ! -f "./$JAR_FILE" ]; then
      echo "Jar $JAR_FILE not found in release. Try to download ..."
      curl --silent -O -J -L "https://github.com/$GITHUB_REPO/releases/download/$LATEST_RELEASE/$JAR_FILE"
    fi 

    # Run JAR_FILE
    java -jar $JAR_FILE
    rc=$?
    echo "$JAR_FILE returned $rc."

    if [ $rc == 1 ]; then
        echo "An error occurred. Waiting $DELAY seconds..."
        sleep $DELAY
    fi
    
    echo "Try to restart... "
    cd .. # Leave release folder
done

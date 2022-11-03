#!/usr/bin/env bash

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

greenEcho() {
    echo -e "${GREEN}$1${NC}"
}
redEcho() {
    echo -e "${RED}$1${NC}"
}
yellowEcho() {
    echo -e "${YELLOW}$1${NC}"
}

#to com preguiça de comentar, esse script roda a api e isso
if [ $OSTYPE == "linux-gnu" ]; then
    TEMPFILE=$(mktemp /tmp/guina-api-XXXXX --suffix ".txt")
    DIR=$(pwd)

    trap endScript EXIT
    trap endScript INT

    if [ $? -eq 0 ]; then
        greenEcho "Temp file created"
    else
        redEcho "Error creating temp file"
        exit
    fi

    while true; do
        gpg --no-symkey-cache --batch --yes --output $TEMPFILE --decrypt ENV.txt.gpg 2>/dev/null >test
        if [ $? -ne 0 ]; then
            redEcho "Error decrypting file, try again"
        else
            break
        fi
    done

    docker pull gustavisk/guina-api:latest
    if [ $? -eq 0 ]; then
        greenEcho "Image pulled"
    else
        redEcho "Error pulling image"
    fi

    docker ps -aq --filter "name=guina-api"
    if [ $? -eq 0 ]; then
        yellowEcho "Container already running"
    fi
    docker stop guina-api
    if [ $? -eq 0 ]; then
        greenEcho "Container stopped"
    else
        redEcho "Error stopping container"

    fi
    docker rm guina-api
    if [ $? -eq 0 ]; then
        greenEcho "Container removed"
    else
        redEcho "Container not removed"
    fi

    yellowEcho "Starting container"
    docker run --name guina-api --env-file $TEMPFILE -d -p 8080:8080 gustavisk/guina-api:latest
    if [ $? -eq 0 ]; then
        greenEcho "Container started"
    else
        redEcho "Error starting container"
    fi
    CONTAINER_ID=$(docker ps --last -1 -q)
    CONTAINER_NAME=$(docker ps --format '{{.Names}}' --filter "id=$CONTAINER_ID")

    docker attach $CONTAINER_NAME

    function endScript() {
        yellowEcho "Closing container"
        rm -rf $TEMPFILE
        if [ $? -eq 0 ]; then
            greenEcho "Temp file $TEMPFILE removed"
        else
            redEcho "Error removing temp file"
        fi

        docker rm $(docker ps -aq --filter "id=$CONTAINER_ID")
        if [ $? -eq 0 ]; then
            greenEcho "Container removed"
        else
            redEcho "Error removing container"
            yellowEcho "Trying to remove container with via container name"
            docker rm -f $(docker ps -aq --filter "name=guina-api")
            if [ $? -eq 0 ]; then
                greenEcho "Container removed"
            else
                redEcho "Error removing container"
                yellowEcho "Try to remove it manually"
            fi

        fi

    }

else
    trap endScriptWin EXIT
    trap endScriptWin INT
    TEMPFILE=$(mktemp /tmp/guina-api-XXXXX --suffix ".txt")
    if [ $? -eq 0 ]; then
        greenEcho "Temp file created"
    else
        redEcho "Error creating temp file"
        exit
    fi

    while true; do
        gpg --no-symkey-cache --batch --yes --output $TEMPFILE --decrypt ENV.txt.gpg 2>/dev/null >test
        if [ $? -ne 0 ]; then
            redEcho "Error decrypting file, try again"
        else
            break
        fi
    done

    docker pull gustavisk/guina-api:latest
    if [ $? -eq 0 ]; then
        greenEcho "Image pulled"
    else
        redEcho "Error pulling image"
    fi

    docker ps -aq --filter "name=guina-api"
    if [ $? -eq 0 ]; then
        yellowEcho "Container already running"
    fi
    docker stop guina-api
    if [ $? -eq 0 ]; then
        greenEcho "Container stopped"
    else
        redEcho "Error stopping container"
    fi
    docker rm guina-api
    if [ $? -eq 0 ]; then
        greenEcho "Container removed"
    else
        redEcho "Container not removed"
    fi

    yellowEcho "Starting container"
    docker run --name guina-api --env-file $TEMPFILE -d -p 8080:8080 gustavisk/guina-api:latest
    if [ $? -eq 0 ]; then
        greenEcho "Container started"
    else
        redEcho "Error starting container"
    fi

    CONTAINER_ID=$(docker ps --last -1 -q)
    CONTAINER_NAME=$(docker ps --format '{{.Names}}' --filter "id=$CONTAINER_ID")

    while true; do
        read -p "Digite X para sair: " out

        if [ "$out" == "X" ]; then
            docker stop $CONTAINER_ID
            rm -rf $TEMPFILE
            docker rm $(docker ps -aq --filter "id=$CONTAINER_ID")
            if [ $? -eq 0 ]; then
                greenEcho "Container removed"
            else
                redEcho "Error removing container"

            fi
            exit
            greenEcho "Saí!"
        fi
    done

    function endScriptWin() {
        yellowEcho "Closing container"
        rm -rf $TEMPFILE
        if [ $? -eq 0 ]; then
            greenEcho "Temp file $TEMPFILE removed"
        else
            redEcho "Error removing temp file"
        fi

        docker rm $(docker ps -aq --filter "id=$CONTAINER_ID")
        if [ $? -eq 0 ]; then
            greenEcho "Container removed"
        else
            redEcho "Error removing container"
            yellowEcho "Trying to remove container with via container name"
            docker rm -f $(docker ps -aq --filter "name=guina-api")
            if [ $? -eq 0 ]; then
                greenEcho "Container removed"
            else
                redEcho "Error removing container"
                yellowEcho "Try to remove it manually"
            fi

        fi

    }

fi

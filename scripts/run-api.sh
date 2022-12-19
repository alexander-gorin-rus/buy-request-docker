#!/usr/bin/env bash
set -e

cd /home/node/$API_SERVER_NAME || exit
if [ "$DOCKER_ENV" != local ]
    then
    npm install && npm run run
else
    npm install && npm run dev
fi

tail -f /dev/null

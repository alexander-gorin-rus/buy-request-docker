#!/usr/bin/env bash

cd /home/node/app/user-service || exit
npm i
npm run build
pm2 start /home/node/app/user-service/dist/src/main.js --name user-service

cd /home/node/app/deal-service || exit
npm i
npm run build
pm2 start /home/node/app/deal-service/dist/src/main.js --name deal-service

cd /home/node/app/product-service || exit
npm i
npm run build
pm2 start /home/node/app/product-service/dist/src/main.js --name product-service

cd /home/node/app/notification-service || exit
npm i
npm run build
pm2 start /home/node/app/notification-service/dist/src/main.js --name notification-service

cd /home/node/app/request-service || exit
npm i
npm run build
pm2 start /home/node/app/request-service/dist/src/main.js --name request-service

cd /home/node/app/feedback-service || exit
npm i
npm run build
pm2 start /home/node/app/feedback-service/dist/src/main.js --name feedback-service

cd /home/node/app/report-service || exit
npm i
npm run build
pm2 start /home/node/app/report-service/dist/src/main.js --name report-service

cd /home/node/app/auth-service || exit
npm i
npm run build
pm2 start /home/node/app/auth-service/dist/src/main.js --name auth-service

cd /home/node/app/chat-service || exit
npm i
npm run build
pm2 start /home/node/app/chat-service/dist/src/main.js --name chat-service

echo 'Ready...'
echo 'Run to connect to the main container: '
echo 'docker-compose exec microservice /bin/bash'
pm2 logs
tail -f /dev/null

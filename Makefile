#!make
include .env
export $(shell sed 's/=.*//' .env)
.PHONY: help docker-env nginx-config
DOCKER-COMPOSE-COMMAND = docker-compose -p ${APP_NAME}-${APP_ENV} --profile ${DOCKER_ENV} -f docker-compose.yml
RUN = ${DOCKER-COMPOSE-COMMAND} run --rm
START = ${DOCKER-COMPOSE-COMMAND} --profile ${DOCKER_ENV} up -d --remove-orphans
STOP = ${DOCKER-COMPOSE-COMMAND} stop
LOGS = docker logs
EXEC = ${DOCKER-COMPOSE-COMMAND} exec

INSTALL = npm i && npm run prebuild && npm run build && pm2 start ./dist/src/main.js
RESTART = npm run build && pm2 start ./dist/src/main.js
STOP_PM2 = pm2 stop

./.env:
	echo APP_NAME=buy-request > $@


ifeq (${DOCKER_ENV},local)
docker-env: clone build-all up
else ifeq (${DOCKER_ENV},dev)
docker-env: clone build-all up
else ifeq (${DOCKER_ENV},staging)
docker-env: clone build-all up
else ifeq (${DOCKER_ENV},prod)
docker-env: clone build-all up
endif

build-ansible:
	@echo "\n\033[01;33m Checking Ansible image \033[0m"
	@docker build -q -t ${APP_NAME}-ansible:latest ./ansible
encrypt-env: build-ansible
	@docker run -it --rm -v ${PWD}/:/ansible ${APP_NAME}-ansible:latest encrypt .env --output=.env.${DOCKER_ENV}.enc
encrypt-certs: build-ansible
	@tar czf ./ssl-cert-${DOCKER_ENV}.tgz ./nginx/ssl/
	@docker run -it --rm -v ${PWD}/:/ansible ${APP_NAME}-ansible:latest encrypt ssl-cert-${DOCKER_ENV}.tgz --output=.ssl-cert-${DOCKER_ENV}.tgz.enc
	@rm ./ssl-cert-${DOCKER_ENV}.tgz
decrypt-env: build-ansible
	@bash ./bin/set-environment
decrypt-certs: build-ansible
	@docker run -it --rm -v ${PWD}/:/ansible ${APP_NAME}-ansible:latest decrypt ./.ssl-cert-${DOCKER_ENV}.tgz.enc --output=ssl-cert-${DOCKER_ENV}.tgz
	@tar xzf ssl-cert-${DOCKER_ENV}.tgz ./nginx/ssl/
	@rm ./ssl-cert-${DOCKER_ENV}.tgz

front-env:
	@bash ./bin/set-front-env

clone: clone-services clone-frontend clone-api

clone-frontend:
	@echo "\n\033[01;33m Cloning frontend repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../${APP_NAME}-dashboard ]; then cd ../${APP_NAME}-dashboard && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${DASHBOARD_GIT_URL} ../${APP_NAME}-dashboard; fi"

clone-services: prepare-services clone-user-service clone-request-service clone-product-service clone-deal-service clone-notification-service clone-feedback-service clone-report-service clone-auth-service clone-chat-service clone-sync-service

prepare-services:
	@echo "\n\033[01;33m Creating services directory \033[0m"
	@bash -c "if [ -d ../services ]; then echo 'directory existed'; else mkdir ../services; fi"

clone-user-service:
	@echo "\n\033[01;33m Cloning user-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${USER_SERVICE_NAME}-service ]; then cd ../services/${USER_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${USER_SERVICE_GIT_URL} ../services/${USER_SERVICE_NAME}-service; fi"

clone-request-service:
	@echo "\n\033[01;33m Cloning request-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${REQUEST_SERVICE_NAME}-service ]; then cd ../services/${REQUEST_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${REQUEST_SERVICE_GIT_URL} ../services/${REQUEST_SERVICE_NAME}-service; fi"

clone-product-service:
	@echo "\n\033[01;33m Cloning product-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${PRODUCT_SERVICE_NAME}-service ]; then cd ../services/${PRODUCT_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${PRODUCT_SERVICE_GIT_URL} ../services/${PRODUCT_SERVICE_NAME}-service; fi"

clone-deal-service:
	@echo "\n\033[01;33m Cloning deal-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${DEAL_SERVICE_NAME}-service ]; then cd ../services/${DEAL_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${DEAL_SERVICE_GIT_URL} ../services/${DEAL_SERVICE_NAME}-service; fi"

clone-notification-service:
	@echo "\n\033[01;33m Cloning notification-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${NOTIFICATION_SERVICE_NAME}-service ]; then cd ../services/${NOTIFICATION_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${NOTIFICATION_SERVICE_GIT_URL} ../services/${NOTIFICATION_SERVICE_NAME}-service; fi"

clone-feedback-service:
	@echo "\n\033[01;33m Cloning feedback-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${FEEDBACK_SERVICE_NAME}-service ]; then cd ../services/${FEEDBACK_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${FEEDBACK_SERVICE_GIT_URL} ../services/${FEEDBACK_SERVICE_NAME}-service; fi"

clone-report-service:
	@echo "\n\033[01;33m Cloning report-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${REPORT_SERVICE_NAME}-service ]; then cd ../services/${REPORT_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${REPORT_SERVICE_GIT_URL} ../services/${REPORT_SERVICE_NAME}-service; fi"

clone-auth-service:
	@echo "\n\033[01;33m Cloning auth-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${AUTH_SERVICE_NAME}-service ]; then cd ../services/${AUTH_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${AUTH_SERVICE_GIT_URL} ../services/${AUTH_SERVICE_NAME}-service; fi"

clone-chat-service:
	@echo "\n\033[01;33m Cloning chat-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${CHAT_SERVICE_NAME}-service ]; then cd ../services/${CHAT_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${CHAT_SERVICE_GIT_URL} ../services/${CHAT_SERVICE_NAME}-service; fi"

clone-sync-service:
	@echo "\n\033[01;33m Cloning sync-service repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../services/${SYNC_SERVICE_NAME}-service ]; then cd ../services/${SYNC_SERVICE_NAME}-service && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${SYNC_SERVICE_GIT_URL} ../services/${SYNC_SERVICE_NAME}-service; fi"

clone-api:
	@echo "\n\033[01;33m Cloning api repository (${GIT_BRANCH_NAME} branch) \033[0m"
	@bash -c "if [ -d ../${API_SERVER_NAME} ]; then cd ../${API_SERVER_NAME} && git fetch && git checkout ${GIT_BRANCH_NAME} && git reset --hard origin/${GIT_BRANCH_NAME}; else git clone -b ${GIT_BRANCH_NAME} ${API_GIT_URL} ../${API_SERVER_NAME}; fi"

ifeq (${DOCKER_ENV},local)
build-all: build-microservice-image build-api-image
else ifeq (${DOCKER_ENV},dev)
build-all: build-microservice-image build-api-image build-frontend-image build-nginx-image
else ifeq (${DOCKER_ENV},staging)
build-all: build-microservice-image build-api-image build-frontend-image build-nginx-image
else ifeq (${DOCKER_ENV},prod)
build-all: build-microservice-image build-api-image build-frontend-image build-nginx-image
endif

api-npm-install:
	@$(RUN) ${API_SERVER_NAME}
	@$(EXEC) ${API_SERVER_NAME} -c "cd /home/node/$API_SERVER_NAME && npm i"

nginx-restart:
	@$(STOP) web-srv
	@$(START) web-srv

dashboard-restart:
	@$(STOP) request-dashboard
	@$(START) request-dashboard

api-restart:
	@$(STOP) dashboard-api
	@$(START) dashboard-api

user-service-restart:
	@$(STOP) ${USER_SERVICE_NAME}-service
	@$(START) ${USER_SERVICE_NAME}-service

product-service-restart:
	@$(STOP) ${PRODUCT_SERVICE_NAME}-service
	@$(START) ${PRODUCT_SERVICE_NAME}-service

notification-service-restart:
	@$(STOP) ${NOTIFICATION_SERVICE_NAME}-service
	@$(START) ${NOTIFICATION_SERVICE_NAME}-service

feedback-service-restart:
	@$(STOP) ${FEEDBACK_SERVICE_NAME}-service
	@$(START) ${FEEDBACK_SERVICE_NAME}-service

report-service-restart:
	@$(STOP) ${REPORT_SERVICE_NAME}-service
	@$(START) ${REPORT_SERVICE_NAME}-service

auth-service-restart:
	@$(STOP) ${AUTH_SERVICE_NAME}-service
	@$(START) ${AUTH_SERVICE_NAME}-service

chat-service-restart:
	@$(STOP) ${CHAT_SERVICE_NAME}-service
	@$(START) ${CHAT_SERVICE_NAME}-service

deal-service-restart:
	@$(STOP) ${DEAL_SERVICE_NAME}-service
	@$(START) ${DEAL_SERVICE_NAME}-service

request-service-restart:
	@$(STOP) ${REQUEST_SERVICE_NAME}-service
	@$(START) ${REQUEST_SERVICE_NAME}-service

build-microservice-image:
	@docker build --no-cache \
	-t ${APP_NAME}-${MICROSERVICE_SERVER_NAME}:latest ./microservice
	@docker tag ${APP_NAME}-${MICROSERVICE_SERVER_NAME}:latest ${AWS_ECR}/${APP_NAME}-${MICROSERVICE_SERVER_NAME}:${DOCKER_ENV}

build-api-image:
	@docker build --no-cache \
	-t ${APP_NAME}-${API_SERVER_NAME}:latest ./api
	@docker tag ${APP_NAME}-${API_SERVER_NAME}:latest ${AWS_ECR}/${APP_NAME}-${API_SERVER_NAME}:${DOCKER_ENV}

build-frontend-image:
	@docker build --no-cache \
	-t ${APP_NAME}-node:latest ./frontend
	@docker tag ${APP_NAME}-node:latest ${AWS_ECR}/${APP_NAME}-react:${DOCKER_ENV}
build-nginx-image: nginx-config
	@docker build --no-cache -t ${APP_NAME}-nginx:latest ./nginx
	@docker tag ${APP_NAME}-nginx:latest ${AWS_ECR}/${APP_NAME}-nginx:${DOCKER_ENV}

nginx-config:
	@echo "\n\033[0;33m Generating nginx config...\033[0m"
#	@bash ./bin/nginx-config

up: front-env
	@echo "\n\033[0;33m Spinning up docker environment... \033[0m"
	@$(START)
	@$(MAKE) --no-print-directory status

stop:
	@echo "\n\033[0;33m Halting containers... \033[0m"
	@$(STOP)
	@$(MAKE) --no-print-directory status

restart: front-env
	@echo "\n\033[0;33m Restarting containers... \033[0m"
	@$(STOP)
	@$(START)
	@$(MAKE) --no-print-directory status

restart-microservice: front-env
	@echo "\n\033[0;33m Restarting microservice container... \033[0m"
	@$(STOP) microservice
	@$(START) microservice
	@$(MAKE) --no-print-directory status

nginx-reload:
	@$(EXEC) web-srv nginx -s reload

nginx-test:
	@$(EXEC) web-srv nginx -t
clean:
	@echo "\033[1;31m\033[5m\t\t\t WARNING! \033[0m"
	@echo "\033[1;31m\033[5m Removing all containers and Applications source directories! \033[0m"
	@echo "\033[1;31m\033[5m Ensure that you have pushed your changes to origin \033[0m"
	@echo "\033[1;31m\033[5m\t\t Are you sure to proceed? \033[0m"
	@$(MAKE) --no-print-directory dialog
	@$(DOCKER-COMPOSE-COMMAND) down --rmi all 2> /dev/null
	@sudo rm -rf nginx/configs/conf.d/*.conf nginx/configs/.htpasswd
	@$(MAKE) --no-print-directory status

clean-images:
	@docker rmi -f \
	${AWS_ECR}/${APP_NAME}-react:${DOCKER_ENV} \
	docker rmi -f ${AWS_ECR}/${APP_NAME}-react:${DOCKER_ENV} \
	${APP_NAME}-nginx:latest \
	${APP_NAME}-${API_SERVER_NAME}:latest \
	${APP_NAME}-${MICROSERVICE_SERVER_NAME}:latest \
	${APP_NAME}-node:latest 2> /dev/null

status:
	@echo "\n\033[0;33m Containers statuses \033[0m"
	@$(DOCKER-COMPOSE-COMMAND) ps

dialog:
	@bash ./bin/dialog

user-service-console:
	@$(EXEC) user-service bash

deal-service-console:
	@$(EXEC) deal-service bash

request-service-console:
	@$(EXEC) request-service bash

product-service-console:
	@$(EXEC) product-service bash

notification-service-console:
	@$(EXEC) notification-service bash

feedback-service-console:
	@$(EXEC) feedback-service bash

report-service-console:
	@$(EXEC) report-service bash

auth-service-console:
	@$(EXEC) auth-service bash

chat-service-console:
	@$(EXEC) chat-service bash

dashboard-console:
	@$(EXEC) request-dashboard bash

api-console:
	@$(EXEC) dashboardapi bash

postgres-console:
	@$(EXEC) postgres bash

nginx-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-nginx

nginx-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-nginx

dashboard-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-dashboard

dashboard-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-dashboard

api-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${API_SERVER_NAME}

api-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${API_SERVER_NAME}

user-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${USER_SERVICE_NAME}-service

user-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${USER_SERVICE_NAME}-service

deal-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${DEAL_SERVICE_NAME}-service

deal-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${DEAL_SERVICE_NAME}-service

product-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${PRODUCT_SERVICE_NAME}-service

product-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${PRODUCT_SERVICE_NAME}-service

notification-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${NOTIFICATION_SERVICE_NAME}-service

notification-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${NOTIFICATION_SERVICE_NAME}-service

request-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${REQUEST_SERVICE_NAME}-service

request-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${REQUEST_SERVICE_NAME}-service

feedback-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${FEEDBACK_SERVICE_NAME}-service

feedback-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${FEEDBACK_SERVICE_NAME}-service

report-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${REPORT_SERVICE_NAME}-service

report-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${REPORT_SERVICE_NAME}-service

auth-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${AUTH_SERVICE_NAME}-service

auth-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${AUTH_SERVICE_NAME}-service

chat-service-logs:
	@$(LOGS) --tail=100 -f ${APP_NAME}-${CHAT_SERVICE_NAME}-service

chat-service-logs-without-tail:
	@$(LOGS) --tail=100 ${APP_NAME}-${CHAT_SERVICE_NAME}-service

ms-logs:
	@$(LOGS) --tail=100 -f ${MINIO_SERVER_NAME}

mc-logs:
	@$(LOGS) --tail=100 -f ${MINIO_CLIENT_NAME}

ms-restart:
	@$(STOP) ${MINIO_SERVER_NAME}
	@$(START) ${MINIO_SERVER_NAME}

mc-restart:
	@$(STOP) ${MINIO_CLIENT_NAME}
	@$(START) ${MINIO_CLIENT_NAME}

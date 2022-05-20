#!/usr/bin/make

## Импортирует переменные окружения
ifeq (0, $(shell [ -f ./.env ] && echo 0))
include .env
else
include .env.example
endif
export

## Команда по умолчанию
.DEFAULT_GOAL := help

## Текущее время
CURRENT_TIME := $(shell date +%F-%H-%M-%S)

## Удаленный сервер
REMOTE_APPLICATION := $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_PATH)
REMOTE_DATABASE := $(REMOTE_USER)@$(REMOTE_HOST):$(REMOTE_DATABASE_PATH)

## Названия контейнеров
CONTAINER_APPLICATION := $(shell docker ps --filter name=_application_ --format {{.Names}})
CONTAINER_SERVER := $(shell docker ps --filter name=_server_ --format {{.Names}})
CONTAINER_DATABASE := $(shell docker ps --filter name=_mysql_ --format {{.Names}})
CONTAINER_DATABASE_MANAGEMENT_SYSTEM := $(shell docker ps --filter name=_database-management-system_ --format {{.Names}})

## Программы Docker и Docker-Compose
DOCKER_BIN := $(shell command -v docker 2> /dev/null)
DOCKER_COMPOSE_BIN := $(shell command -v docker-compose 2> /dev/null)

# --- [ Docker ] -------------------------------------------------------------------------------------------------------
## Отображает информацию о контейнерах
status:
	@$(DOCKER_BIN) ps -as

## Собирает все контейнеры
build:
	@$(DOCKER_COMPOSE_BIN) build
	@echo 'Завершение сборки всех контейнеров'

## Собирает application
build-application:
	@$(DOCKER_COMPOSE_BIN) build application
	@echo 'Завершение сборки application'

## Собирает server
build-server:
	@$(DOCKER_COMPOSE_BIN) build server
	@echo 'Завершение сборки server'

## Собирает database
build-database:
	@$(DOCKER_COMPOSE_BIN) build database
	@echo 'Завершение сборки database'

## Собирает database-management-system
build-database-management-system:
	@$(DOCKER_COMPOSE_BIN) build database-management-system
	@echo 'Завершение сборки database-management-system'

## Запускает все контейнеры
start:
	@if [ ! -d ./src$(APPLICATION_FOLDER) ]; then mkdir -p ./src$(APPLICATION_FOLDER); fi
	@$(DOCKER_COMPOSE_BIN) up -d --remove-orphans
	@echo 'Завершение запуска всех контейнеров'

## Пересобирает и запускает все контейнеры
up: build start

## Завершает работу всех контейнеров
down:
	@$(DOCKER_COMPOSE_BIN) down
	@echo 'Завершение всех контейнеров'

## Перезапускает все контейнеры
reset: down start
	@echo 'Завершение перезапуска всех контейнеров'

## Перезапускает application
reset-application:
	@echo 'Начало перезапуска application'
	@$(DOCKER_COMPOSE_BIN) restart application
	@echo 'Завершение перезапуска application'

## Перезапускает server
reset-server:
	@echo 'Начало перезапуска server'
	@$(DOCKER_COMPOSE_BIN) restart server
	@echo 'Завершение перезапуска server'

## Перезапускает database
reset-database:
	@echo 'Начало перезапуска database'
	@$(DOCKER_COMPOSE_BIN) restart database
	@echo 'Завершение перезапуска database'

## Перезапускает database-management-system
reset-database-management-system:
	@echo 'Начало перезапуска database-management-system'
	@$(DOCKER_COMPOSE_BIN) restart database-management-system
	@echo 'Завершение перезапуска database-management-system'

## Пересобирает и перезапускает все контейнеры
restart: build down up
	@echo 'Завершение пересборки и перезапуска всех контейнеров'

## Пересобирает и перезапускает application
restart-application: build-application reset-application
	@echo 'Завершение пересборки и перезапуска application'

## Пересобирает и перезапускает server
restart-server: build-server reset-server
	@echo 'Завершение пересборки и перезапуска server'

## Пересобирает и перезапускает database
restart-database: build-database reset-database
	@echo 'Завершение пересборки и перезапуска database'

## Пересобирает и перезапускает database-management-system
restart-database-management-system: build-database-management-system reset-database-management-system
	@echo 'Завершение пересборки и перезапуска database-management-system'

## Останавливает все контейнеры
stop:
	@$(DOCKER_BIN) ps -aq | xargs -r $(DOCKER_BIN) stop
	@echo 'Завершение остановки всех контейнеров'

## Очищает систему от неиспользуемых/висячих/незапущенных контейнеров и образов
prune:
	@$(DOCKER_BIN) system prune -af
	@echo 'Завершение очистки от неиспользуемых/висячих/незапущенных контейнеров и образов'

## Удаляет все контейнеры и образы
remove: remove-containers remove-images
	@echo 'Завершение удаления всех контейнеров и образов'

## Удаляет все файлы приложени, контейнеры и образы
remove-all: remove-application remove

## Удаляет все контейнеры
remove-containers:
	@echo 'Начало удаления всех контейнеров'
	@$(DOCKER_BIN) ps -aq | xargs -r $(DOCKER_BIN) rm -vf
	@echo 'Завершение удаления всех контейнеров'

## Удаляет все образы
remove-images:
	@echo 'Начало удаления всех образов'
	@$(DOCKER_BIN) images -q | xargs -r $(DOCKER_BIN) rmi
	@echo 'Завершение удаления всех образов'

## Удаляет все файлы приложения
remove-application:
	@echo 'Начало удаления всех файлов приложения'
	@if [ -n "$(CONTAINER_APPLICATION)" ]; then \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_APPLICATION) sh -c "if [ -d /var/www/html ]; then cd /var/www/html && rm -rf ..?* .[!.]* *; fi"; \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_APPLICATION) sh -c "find /var/log/app/ ! -name '.gitkeep' ! -name 'app' -delete"; \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_APPLICATION) sh -c "find /var/log/php/ ! -name '.gitkeep' ! -name 'php' -delete"; \
	fi
	@if [ -n "$(CONTAINER_SERVER)" ]; then \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_SERVER) sh -c "find /var/log/nginx/ ! -name '.gitkeep' ! -name 'nginx' -delete"; \
	fi
	@if [ -n "$(CONTAINER_DATABASE)" ]; then \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_DATABASE) sh -c "find /var/log/mysql/ ! -name '.gitkeep' ! -name 'mysql' -delete"; \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_DATABASE) sh -c "find /backup/ ! -name '.gitkeep' ! -name 'backup' -delete"; \
	$(DOCKER_BIN) exec -itw / $(CONTAINER_DATABASE) sh -c "find /var/lib/mysql/ ! -name '.gitignore' ! -name 'mysql' -delete"; \
	fi
	@find ./src/ ! -name '.gitkeep' ! -name 'src' -delete
	@echo 'Завершение удаления всех файлов приложения'

# --- [ Application ] --------------------------------------------------------------------------------------------------
## Разворачивание приложения
deploy: up application-load database-load composer-install npm-install
	@echo 'Завершение разворачивания приложения'

## Получает файлы приложения
application-load: application-clone application-pull application-setup
	@echo 'Завершение получения файлов приложения'

## Клонирует репозиторий
application-clone:
	@echo 'Начало клонирования репозитория'
	rm -rf ./src$(APPLICATION_FOLDER) && \
	mkdir ./src$(APPLICATION_FOLDER) && \
	git clone $(APPLICATION_REPOSITORY) ./src$(APPLICATION_FOLDER)/.
	@echo 'Завершение клонирования репозитория'

## Получает папки bitrix и upload, и файл .htaccess
application-pull:
	@echo 'Начало получения папки bitrix'
	rsync -avze 'ssh -p$(REMOTE_PORT)' --exclude 'bitrix/backup/' --exclude 'bitrix/*cache/' $(REMOTE_APPLICATION)/bitrix ./src$(APPLICATION_FOLDER)/.
	@echo 'Завершение получения папки bitrix'
	@echo 'Начало получения папки upload'
	rsync -ave 'ssh -p$(REMOTE_PORT)' --exclude 'upload/disk/' $(REMOTE_APPLICATION)/upload ./src$(APPLICATION_FOLDER)/.
	@echo 'Завершение получения папки upload'
	@echo 'Начало получения файла .htaccess'
	rsync -avze 'ssh -p$(REMOTE_PORT)' $(REMOTE_APPLICATION)/.htaccess ./src$(APPLICATION_FOLDER)/.
	@echo 'Завершение получения файла .htaccess'

## Настраивает доступы к приложению
application-setup:
	@echo 'Начало настроки доступов к приложению'
	@echo 'Настройка .settings.php'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) sh -c "sed -ie "\""s/'host'.*=>.*/'host' => 'database',/;s/'database'.*=>.*/'database' => '$(DATABASE_NAME)',/;s/'login'.*=>.*/'login' => '$(DATABASE_USER)',/;s/'password'.*=>.*/'password' => '$(DATABASE_PASSWORD)',/;"\"" ./bitrix/.settings.php && rm ./bitrix/.settings.phpe"
	@echo 'Настройка dbconn.php'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) sh -c "sed -ie "\""s/DBHost.*=.*/DBHost = 'database';/;s/DBName.*=.*/DBName = '$(DATABASE_NAME)';/;s/DBLogin.*=.*/DBLogin = '$(DATABASE_USER)';/;s/DBPassword.*=.*/DBPassword = '$(DATABASE_PASSWORD)';/"\"" ./bitrix/php_interface/dbconn.php && rm ./bitrix/php_interface/dbconn.phpe"
	@echo 'Завершение настроки доступов к приложению'

# --- [ Database ] -----------------------------------------------------------------------------------------------------
## Получает бэкап базы данных с удаленного сервера и разворачивает его
database-load: database-pull database-drop database-create database-restore

## Получает бэкап базы данных с удаленного сервера
database-pull:
	@echo 'Начало получения бэкапа базы данных с удаленного сервера'
	rsync -avze 'ssh -p$(REMOTE_PORT)' $(REMOTE_DATABASE) ./database/backup/$(DATABASE_RESTORE_NAME).sql
	@echo 'Завершение получения бэкапа базы данных с удаленного сервера'

## Создает новую базу данных
database-create:
	@echo 'Создание базы данных'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) \
	sh -c "echo 'CREATE DATABASE $(DATABASE_RESTORE_NAME) CHARACTER SET utf8 COLLATE utf8_unicode_ci;' | \
	mysql -u$(DATABASE_USER) -p$(DATABASE_PASSWORD)"

## Удаляет базу данных
database-drop:
	@echo 'Начало удаления базы данных'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) \
	sh -c "echo 'DROP DATABASE IF EXISTS $(DATABASE_RESTORE_NAME);' | \
	mysql -u$(DATABASE_USER) -p$(DATABASE_PASSWORD)"
	@echo 'Завершение удаления базы данных'

## Создает бэкап базы данных
database-backup:
	@echo 'Начало создания бэкапа базы данных'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) \
	sh -c "mysqldump -u$(DATABASE_USER) -p$(DATABASE_PASSWORD) $(DATABASE_RESTORE_NAME) > /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql"
	@echo 'Завершение создания бэкапа базы данных'

## Создает бэкап базы данных и архивирует его с сжатием gzip
database-backup-tar-gzip: database-backup
	@echo 'Начало сжатия бэкапа базы данных с типом gzip'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) \
	sh -c "tar -zcf /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql.tar.gz /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql && rm /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql"
	@echo 'Завершение сжатия бэкапа базы данных с типом gzip'

## Создает бэкап базы данных и архивирует его с сжатием bzip
database-backup-tar-bzip: database-backup
	@echo 'Начало сжатия бэкапа базы данных с типом bzip'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) \
	sh -c "tar -jcf /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql.tar.bz2 /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql && rm /backup/$(DATABASE_BACKUP_NAME)_$(CURRENT_TIME).sql"
	@echo 'Завершение сжатия бэкапа базы данных с типом bzip'

## Разворачивает бэкап базы данных
database-restore:
	@echo 'Начало разворачивания базы данных из бэкапа'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) sh -c "mysql -u$(DATABASE_USER) -p$(DATABASE_PASSWORD) $(DATABASE_NAME) < /backup/$(DATABASE_BACKUP_NAME).sql"
	@echo 'Завершение разворачивания базы данных из бэкапа'

# --- [ Composer ] -----------------------------------------------------------------------------------------------------
## Устанавливает все зависимости Composer
composer-install:
	@echo 'Начало установки всех зависимостей Composer'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) sh -c "if [ -f .$(COMPOSER_FOLDER)composer.json ]; then cd .$(COMPOSER_FOLDER) && composer install; fi"
	@echo 'Завершение установки всех зависимостей Composer'

## Обновляет все зависимости Composer
composer-update:
	@echo 'Начало обновления всех зависимостей Composer'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) sh -c "if [ -f .$(COMPOSER_FOLDER)composer.json ]; then cd .$(COMPOSER_FOLDER) && composer update; fi"
	@echo 'Завершение обновления всех зависимостей Composer'

# --- [ Node JS ] ------------------------------------------------------------------------------------------------------
## Устанавливает все зависимости Node JS
npm-install:
	@echo 'Начало установки всех зависимостей Node JS'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) sh -c "if [ -f .$(NODEJS_FOLDER)package.json ]; then cd .$(NODEJS_FOLDER) && npm install; fi"
	@echo 'Завершение обновления всех зависимостей Node JS'

# --- [ Containers ] ---------------------------------------------------------------------------------------------------
## Входит в контейнер приложения
container-application:
	@echo 'Подключение к application'
	@$(DOCKER_BIN) exec -it $(CONTAINER_APPLICATION) bash
	@echo 'Выход из application'

## Входит в контейнер сервера
container-server:
	@echo 'Подключение к server'
	@$(DOCKER_BIN) exec -it $(CONTAINER_SERVER) bash
	@echo 'Выход из server'

## Входит в контейнер базы данных
container-database:
	@echo 'Подключение к database'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE) bash
	@echo 'Выход из database'

## Входит в контейнер системы управления базы данных
container-database-management-system:
	@echo 'Подключение к database-management-system'
	@$(DOCKER_BIN) exec -it $(CONTAINER_DATABASE_MANAGEMENT_SYSTEM) bash
	@echo 'Выход из database-management-system'

# --- [ Help ] ---------------------------------------------------------------------------------------------------------
## Отображает помощь
help:
	@if [ "true" = "$(CONSOLE_COLOR)" ]; then \
	echo "\033[1;33m+------------------------------------------+\n| Список доступных комманд в Bitrix-Docker |\n+------------------------------------------+\033[0m\n" && \
	echo "\033[1;1mИспользование: make [КОМАНДА]\033[0m\n" && \
	awk 'BEGIN {FS = ":"} /^##.*?/ {printf "\n%s", $$1} /^[a-zA-Z_-]+:/ {printf ":%s\n", $$1} /^# ---/ {printf "\n%s\n", $$1}' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":"} /^##.*?:/ {print $$2, $$1} /\[.*?\]/ {print}' | \
	sed 's/# -* \(.*\) -*/\1/' | \
	awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+/ {printf " \033[1;35m%-38s\033[0m\t- %s\n", $$1, $$2} /\[.*?\]/ {printf "\n\033[1;1m%s\033[0m\n", $$1}' && \
	echo "\n"; \
	else \
	echo "\033[1;1m+------------------------------------------+\n| Список доступных комманд в Bitrix-Docker |\n+------------------------------------------+\033[0m\n" && \
	echo "\033[1;1mИспользование: make [КОМАНДА]\033[0m\n" && \
	awk 'BEGIN {FS = ":"} /^##.*?/ {printf "\n%s", $$1} /^[a-zA-Z_-]+:/ {printf ":%s\n", $$1} /^# ---/ {printf "\n%s\n", $$1}' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":"} /^##.*?:/ {print $$2, $$1} /\[.*?\]/ {print}' | \
	sed 's/# -* \(.*\) -*/\1/' | \
	awk 'BEGIN {FS = "##"} /^[a-zA-Z_-]+/ {printf " \033[1;1m%-38s\033[0m\t- %s\n", $$1, $$2} /\[.*?\]/ {printf "\n\033[1;1m%s\033[0m\n", $$1}' && \
	echo "\n"; \
	fi

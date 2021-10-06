# Bitrix-Docker

## Репозиторий проекта
[https://git.arealidea.ru/areal/bitrix-docker.git](https://git.arealidea.ru/areal/bitrix-docker.git)

## Установка docker и docker-compose
[https://docs.docker.com/install/](https://docs.docker.com/install/)

## Команды Bitrix-Docker
Список доступных команд можно получить вводном **в корне** сборки Bitrix-Docker командами
```bash
make help
```
или просто выполнить
```bash
make
```

Также в самом низу этого руководства находится [список всех команд](#commands)

## Docker для проектов на Bitrix
Сборка Bitrix-Docker предназначена для использования Docker'а **без совместного хранения** его с репозиторием проекта в одном монолите.

Но это не мешает хранить настроенную под себя сборку в отдельной независимой от основной ветке. Для этого потребуется:
1. Создать и переключиться в новую ветку от основной ветки
```bash
git checkout master
git checkout -b bitrixDocker
```
2. Удалить все коммиты из этой ветки
```bash
git log --format="%H" | tail -1 | xargs git reset --hard
```
3. Удалить все файлы кроме **.git**
4. Развернуть в **сторонней папке** Bitrix-Docker
5. Удалить **.git** у самой сборки Bitrix-Docker
6. Перенести сборку Bitrix-Docker в очищенную папку своего проекта
7. Закоммитить затерев первый коммит в этой ветке
```bash
git add --all
git commit --amend -m "init: инициализирует сборку Bitrix-Docker"
```
8. Запушить в удаленный репозиторий в ветку с таким же названием
```bash
git push origin bitrixDocker
```
9. [Развернуть существующий проект](#deploy)
>Теперь если потребуется поменять настройки сборки, то не надо искать отдельный репозиторий со сборкой, легко поправить конфигурацию закомитить и запушить в ветку со сборкой.
>
>Также просто разворачивать на боевом сервере без использользования Docker обертки, из-за которой требовалось класть само приложение в стороннюю папку и "тянуть" символьную ссылку, что нарушало структуру проектов на сервере.

## Разворачивание чистого проекта
1. Зайти в папку проекта
2. Инициализировать git-репозиторий
```bash
git init
```
3. Настроить имя пользователя и e-mail разработчика
```bash
git config --global user.name "Name Surname"
git config --global user.email "name.surname@mail.com"
```
4. Настроить глобальный .gitignore, создать сам файл .gitignore и добавить в список папки и файлы от различных редакторов
```bash
git config --global core.excludesfile '~/.gitignore'
touch ~/.gitignore
echo '.idea' >> ~/.gitignore
```
5. Создать в проекте свой .gitignore и прописать все, что не должно войти в репозиторий:
- Папка bitrix
- Папка upload
- Файл .htaccess
- Файл .htsecure
- Различные файлы SEO (\*.xml, google_\*.html, yandex_\*.html, robots.txt...)
- И другие
6. Закоммитить командами
```bash
git add --all
git commit -m "init: инициализирует проект"
```
7. Запушить в предоставленный репозиторий командой
```bash
git push -u origin master
```
8. [Развернуть новосозданный проект](#deploy)

<a name="deploy"></a>
## Разворачивание существующего проекта на площадке
1. Скопировать и переименовать файл конфигурации .env.example в .env
2. Настроить .env под свой проект
3. Запустить команду
```bash
make deploy
```
>Если конфигурация больше не будет меняться, то можно ввести команду при запущенном **Docker'е**, которая очистит проект от лишних контейнеров и образов занимаемые ваш диск
>```bash
>make prune
>```

## В последующих запусках проекта
- Запустить команду
```bash
make up
```

## Остановить запущенный проект
- Запустить команду
```bash
make down
```

<a name="commands"></a>
## Список всех доступных комманд
Команды | Описание
:---| ---
--- **Docker** ------------------ |
**status** |  Отображает информацию о контейнерах
**build** |  Собирает все контейнеры
**build-application** |  Собирает application
**build-server** |  Собирает server
**build-database** |  Собирает database
**build-database-management-system** |  Собирает database-management-system
**start** |  Запускает все контейнеры
**up** |  Пересобирает и запускает все контейнеры
**down** |  Завершает работу всех контейнеров
**reset** |  Перезапускает все контейнеры
**reset-application** |  Перезапускает application
**reset-server** |  Перезапускает server
**reset-database** |  Перезапускает database
**reset-database-management-system** |  Перезапускает database-management-system
**restart** |  Пересобирает и перезапускает все контейнеры
**restart-application** |  Пересобирает и перезапускает application
**restart-server** |  Пересобирает и перезапускает server
**restart-database** |  Пересобирает и перезапускает database
**restart-database-management-system** |  Пересобирает и перезапускает database-management-system
**stop** |  Останавливает все контейнеры
**prune** |  Очищает систему от неиспользуемых/висячих/незапущенных контейнеров и образов
**remove** |  Удаляет все контейнеры и образы
**remove-all** |  Удаляет все файлы приложени, контейнеры и образы
**remove-containers** |  Удаляет все контейнеры
**remove-images** |  Удаляет все образы
**remove-application** |  Удаляет все файлы приложения
--- **Application** ------------------ |
**deploy** |  Разворачивание приложения
**application-load** |  Получает файлы приложения
**application-clone** |  Клонирует репозиторий
**application-pull** |  Получает папки bitrix и upload, и файл .htaccess
**application-setup** |  Настраивает доступы к приложению
--- **Database** ------------------ |
**database-load** |  Получает бэкап базы данных с удаленного сервера и разворачивает его
**database-pull** |  Получает бэкап базы данных с удаленного сервера
**database-create** |  Создает новую базу данных
**database-drop** |  Удаляет базу данных
**database-backup** |  Создает бэкап базы данных
**database-backup-tar-gzip** |  Создает бэкап базы данных и архивирует его с сжатием gzip
**database-backup-tar-bzip** |  Создает бэкап базы данных и архивирует его с сжатием bzip
**database-restore** |  Разворачивает бэкап базы данных
--- **Composer** ------------------ |
**composer-install** |  Устанавливает все зависимости Composer
**composer-update** |  Обновляет все зависимости Composer
--- **Node JS** ------------------ |
**npm-install** |  Устанавливает все зависимости Node JS
--- **Containers** ------------------ |
**container-application** |  Входит в контейнер приложения
**container-server** |  Входит в контейнер сервера
**container-database** |  Входит в контейнер базы данных
**container-database-management-system** |  Входит в контейнер системы управления базы данных
--- **Help** ------------------ |
**help** |  Отображает помощь

## Контакты
Areal E-mail: [hello@arealidea.ru](hello@arealidea.ru)

Личный E-mail: [ajieksmaximov@gmail.com](ajieksmaximov@gmail.com)

Автор: Алексей Максимов

© Areal 2019 г.

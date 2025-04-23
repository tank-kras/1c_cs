# Сервер взаимодействия 1C в Docker

Статья на ИТС https://its.1c.ru/db/cs27doc

Перед использованием надо создать папку `/distr` и поместить туда архив `1c_cs_27.0.34_linux_x86_64.tar.gz`

## Сборка

`docker build -t cs:v27 -f ./cs/Dockerfile . --no-cache`

## Настройка Postgres

сначала нужно запустить контейнер с Postgres

`docker run -p 15432:5432 postgres`

подождать 30 секунд пока Postgres запуститься
затем внури контейнера в файле `/var/lib/postgresql/data/pg_hba.conf`, в конце файла добавить `host    all             all             0.0.0.0/0               md5`

внутри контейнера postgres необходимо создать базу

```
Вводим
CREATE DATABASE cs OWNER postgres;
\c cs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

где cs имя базы

## Запуск

запуск контейнера сервера взаимодействия

`docker run -ti --name cs --link postgres:postgres -e POSTGRES_URL=postgres:5432/cs -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -p 8181:8181 -p 8087:8087 -p 9300:9300 -p 8080:8080 -p 5701:5701 -p 9094:9094 cs:v27`

## Инициализация базы

внутри контейнера (выполняется автоматически):

`curl -Sf -X POST -H "Content-Type: application/json" -d "{ \"url\" : \"jdbc:postgresql://postgres:5432/cs\", \"username\" : \"postgres\", \"password\" : \"postgres\", \"enabled\" : true }" -u admin:admin http://localhost:8087/admin/bucket_server`

где адрес СУБД postgres это имя контейнера

## Проверка работоспособности

внутри контейнера (выполняется автоматически): 

`sudo curl http://localhost:8087/rs/healt`

## Подключение

в ИБ через внешнею обработку подключения вести адрес

`ws://localhost:9094`

Обработку подключения см. на странице дистрибутива сервера взаимодействия 1С
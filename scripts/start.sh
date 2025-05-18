#!/bin/sh

JAVA_HOME_PATH="/usr/lib/jvm/jdk-11.0.14.1-bellsoft-x86_64"

CONFIG_FILE1="/etc/default/1C/1CE/1ce-cs_instance"
CONFIG_FILE2="/etc/default/1C/1CE/1ce-elastic_instance"
CONFIG_FILE3="/etc/default/1C/1CE/1ce-hc_instance"

echo "JAVA_HOME=$JAVA_HOME_PATH" | sudo tee -a "$CONFIG_FILE1"
echo "JAVA_HOME=$JAVA_HOME_PATH" | sudo tee -a "$CONFIG_FILE2"
echo "JAVA_HOME=$JAVA_HOME_PATH" | sudo tee -a "$CONFIG_FILE3"

ring cs --instance cs_instance service stop
ring cs --instance cs_instance service start
echo "Статус cs_instance"
ring cs --instance cs_instance service status

ring elasticsearch --instance elastic_instance service stop
ring elasticsearch --instance elastic_instance service start
echo "Статус elastic_instance"
ring elasticsearch --instance elastic_instance service status

ring hazelcast --instance hc_instance service stop
ring hazelcast --instance hc_instance service start
echo "Статус hc_instance"
ring hazelcast --instance hc_instance service status

echo "Пауза 60 сек"
sleep 60

echo "Инициализация базы"
curl -Sf -X POST -H "Content-Type: application/json" \
-d "{ \"url\" : \"jdbc:postgresql://$POSTGRES_URL\", \"username\" : \"$POSTGRES_USER\", \"password\" : \"$POSTGRES_PASSWORD\", \"enabled\" : true }" -u admin:admin http://localhost:8087/admin/bucket_server

echo "Проверка работоспособности"
sudo curl http://localhost:8087/rs/health

tail -f /dev/null

exec "$@"
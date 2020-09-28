Based on [pluralsight course](https://app.pluralsight.com/library/courses/kafka-connect-fundamentals/table-of-contents).
This example use debezium docker to startup kafka broker and kafka connect, usage of some custom connectors: elasticsearch, mongodb

```bash
# start zookeper
docker run -it --rm \
--name zookeeper \
-p 2181:2181 -p 2888:2888 -p 3888:3888 \
--network debezium-demo \
zookeeper:3.5.5

# start kafka broker
docker run -it --rm \
--name kafka \
-p 9092:9092 \
--link zookeeper:zookeeper \
--network debezium-demo \
debezium/kafka:1.0

# start mysql
docker run -it --rm \
--name mysql \
-p 3306:3306 \
-v "$(pwd)"/mysql.cnf:/etc/mysql/conf.d/mysql.cnf \
-e MYSQL_ROOT_PASSWORD=password \
-e MYSQL_USER=globomantics \
-e MYSQL_PASSWORD=password \
-e MYSQL_DATABASE=globomantics  \
--network debezium-demo \ 
mysql:5.7

docker run -it --rm \
--name mysqlterm \
--link mysql \
mysql:5.7 \
sh -c 'exec mysql \
-h "$MYSQL_PORT_3306_TCP_ADDR" \
-P "$MYSQL_PORT_3306_TCP_PORT" \
-uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'

## run all comands from queries_init.sql file in `mysqlterm`

# start kafka connect
docker run -it --rm --name connect -p 8083:8083 \
-e GROUP_ID=1 \
-e CONFIG_STORAGE_TOPIC=kafka_connect_configs \
-e OFFSET_STORAGE_TOPIC=kafka_connect_offsets \
-e STATUS_STORAGE_TOPIC=kafka_connect_statuses \
--link zookeeper:zookeeper \
--link kafka:kafka \
--link mysql:mysql \
--network debezium-demo \ 
debezium/connect:1.0

# kafka connect rest api shoulb be available
curl -H "Accept:application/json" localhost:8083/

# we can verify what topics been created within kafka broker
docker exec -it kafka bash
cd bin
./kafka-topics.sh --list --bootstrap-server {kafkaIp} # kafkaIp might be found in broker logs: Awaiting socket connections on 172.17.0.6:9092.
# you should see 4 topics been created

# check that no existring connectors
curl -H "Accept:application/json" localhost:8083/connectors/

# deploy mysql connector
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d '
{
  "name": "articles-connector",
  "config": {
    "connector.class": "io.debezium.connector.mysql.MySqlConnector",
    "tasks.max": "1",
    "database.hostname": "mysql",
    "database.port": "3306",
    "database.user": "globomantics",
    "database.password": "password",
    "database.server.id": "223344",
    "database.server.name": "globomantics",
    "database.whitelist": "globomantics",
    "database.history.kafka.bootstrap.servers": "kafka:9092",
    "database.history.kafka.topic": "schema-changes"
    }
}'

# you can verify that new topics been created:
# globomantics, globomantics.globomantics.articles, schema-changes
docker exec -it kafka bash
cd bin
./kafka-topics.sh --list --bootstrap-server {kafkaIp} # kafkaIp might be found in broker logs: Awaiting socket connections on 172.17.0.6:9092.

# you can consume messages from this topics
./kafka-console-consumer.sh --bootstrap-server {kafkaIp} \
--topic globomantics.globomantics.articles \
--from-beginning

# now you can run q from queries.update.sql you see that changes consumer by your consumer

# start elasticsearch
docker run -it --rm \
--name elasticsearch \
-p 9200:9200 -p 9300:9300 \
-e "discovery.type=single-node" \
elasticsearch:7.4.1

# download elastic connector from https://www.confluent.io/hub/confluentinc/kafka-connect-elasticsearch
# to elastic-connector
# start Kafka Connect Worker 2
docker run -it --rm --name connect-2 -p 8084:8083 \
-v "$(pwd)"/elastic-connector/lib:/kafka/connect/elasticsearch/ \
-v "$(pwd)"/mongo-native-connector/lib:/kafka/connect/mongoNative/ \
-e  GROUP_ID=1 \
-e CONFIG_STORAGE_TOPIC=kafka_connect_configs \
-e OFFSET_STORAGE_TOPIC=kafka_connect_offsets \
-e STATUS_STORAGE_TOPIC=kafka_connect_statuses \
-e KAFKA_CONNECT_PLUGINS_DIR=/kafka/connect/ \
--link zookeeper:zookeeper \
--link kafka:kafka \
--link mysql:mysql \
--link elasticsearch:elasticsearch \
--link mongo1:mongo1 \
--link mongo2:mongo2 \
--link mongo3:mongo3 \
--network debezium-demo \
debezium/connect:1.0

# stop Kafka Connect Worker 1
docker stop connect

# start Kafka Connect Worker 1
docker run -it --rm --name connect-1 -p 8083:8083 \
-v "$(pwd)"/elastic-connector/lib:/kafka/connect/elasticsearch/ \
-v "$(pwd)"/mongo-native-connector/lib:/kafka/connect/mongoNative/ \
-e  GROUP_ID=1 \
-e CONFIG_STORAGE_TOPIC=kafka_connect_configs \
-e OFFSET_STORAGE_TOPIC=kafka_connect_offsets \
-e STATUS_STORAGE_TOPIC=kafka_connect_statuses \
-e KAFKA_CONNECT_PLUGINS_DIR=/kafka/connect/ \
--link zookeeper:zookeeper \
--link kafka:kafka \
--link mysql:mysql \
--link elasticsearch:elasticsearch \
--link mongo1:mongo1 \
--link mongo2:mongo2 \
--link mongo3:mongo3 \
--network debezium-demo \
debezium/connect:1.0

# deploy elasticsearch task
curl -H "Accept:application/json" localhost:8084/connectors/articles-connector/status

curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8084/connectors/ -d '
{  
  "name": "elasticsearch-connector",
  "config": { 
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "1", 
    "topics": "globomantics.globomantics.articles", 
    "key.ignore": "true", "schema.ignore": "true", 
    "connection.url": "http://elasticsearch:9200", 
    "type.name": "kafka-connect", 
    "name": "elasticsearch-connector"  
  } 
}'

# you can verify going in browser to: http://localhost:9200/globomantics.globomantics.articles/_search

```
# Standalone mode

```bash
docker-compose up kafka-cluster

# map volumes into docker container
# should be executed from the root of the project
docker run --rm -it -v "$(pwd)":/tutorial --net=host landoop/fast-data-dev bash
kafka-topics --create \
--topic demo-1-standalone \
--partitions 3 \
--replication-factor 1 \
--zookeeper 127.0.0.1:2181

cd tutorial/source/demo1

# create standalone connector
connect-standalone worker.properties file-stream-demo-standalone.properties

# now go source/demo1/ edit demo-file.txt and save it,
# go to http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/demo-1-standalone/
# you will see your edit in topic
# pay attention that each line have be ended with \n
```


# Distributed mode
```bash
# you can skip steps of compose up and map of volumes you if did it standalone mode already
docker-compose up kafka-cluster
# map volumes into docker container
# should be executed from the root of the project
docker run --rm -it -v "$(pwd)":/tutorial --net=host landoop/fast-data-dev bash

kafka-topics --create --topic demo-2-distributed \
--partitions 3 \
--replication-factor 1 \
--zookeeper 127.0.0.1:2181
# http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/demo-2-distributed/
# topic should be created and empty

# go to http://localhost:3030/kafka-connect-ui/#/cluster/fast-data-dev/create-connector/org.apache.kafka.connect.file.FileStreamSourceConnector
# and copypaste configuration from file-stream-demo-distributed.properties and create

# or make http request 
curl -X POST   /api/kafka-connect/connectors   -H 'Content-Type: application/json'   -H 'Accept: application/json'   -d '{
  "name": "file-stream-demo-distributed",
  "config": {
    "connector.class": "org.apache.kafka.connect.file.FileStreamSourceConnector",
    "tasks.max": "1",
    "file": "demo-file.txt",
    "topic": "demo-2-distributed",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true"
  }
}'

# in order to see that it works file should be created on kafka connect cluster - one that we created in the first line  docker-compose up kafka-cluster
# so that we need is to enter connect of cluster and create there file

KAFKA_CLUSTER=$(docker inspect --format="{{.Id}}" kafka-connect-example_kafka-cluster_1)
docker exec -it $KAFKA_CLUSTER bash
touch demo-file.txt
echo "hi" >> demo-file.txt


# we can now read data from topic
docker run --rm -it --net=host landoop/fast-data-dev bash
kafka-console-consumer --topic demo-2-distributed \
--from-beginning \
--bootstrap-server 127.0.0.1:9092
```
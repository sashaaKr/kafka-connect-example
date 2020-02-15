docker-compose up kafka-cluster

docker run --rm -it -v "$(pwd)":/tutorial --net=host landoop/fast-data-dev bash

cd tutorial/source/demo1

kafka-topics --create --topic demo-1-standalone --partitions 3 --replication-factor 1 --zookeeper 127.0.0.1:2181
connect-standalone worker.properties file-stream-demo-standalone.properties




# ===========================
kafka-topics --create --topic demo-2-distributed --partitions 3 --replication-factor 1 --zookeeper 127.0.0.1:2181
kafka-console-consumer --topic demo-2-distributed --from-beginning --bootstrap-server 127.0.0.1:9092

kafka-topics --create --topic demo-3-twitter --partitions 3 --replication-factor 1 --zookeeper 127.0.0.1:2181
kafka-console-consumer --topic demo-3-twitter --from-beginning --bootstrap-server 127.0.0.1:9092
kafka-topics --delete --topic demo-3-twitter --zookeeper 127.0.0.1:2181
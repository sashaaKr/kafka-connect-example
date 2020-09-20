kafka-topics --create --topic demo-3-twitter --partitions 3 --replication-factor 1 --zookeeper 127.0.0.1:2181
kafka-console-consumer --topic demo-3-twitter --from-beginning --bootstrap-server 127.0.0.1:9092
kafka-topics --delete --topic demo-3-twitter --zookeeper 127.0.0.1:2181
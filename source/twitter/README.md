We are using https://github.com/Eneco/kafka-connect-twitter in this example,

Requirements: [twitter dev account shoulb be created before](https://github.com/Eneco/kafka-connect-twitter#creating-a-twitter-application).


```bash
docker-compose up kafka-cluster
# http://localhost:3030 to see that everything are running

docker run --rm -it --net=host lensesio/fast-data-dev bash
kafka-topics --create --topic demo-twitter \
--partitions 3 \
--replication-factor 1 \
--zookeeper 127.0.0.1:2181
# topic should be created and empty: http://localhost:3030/kafka-topics-ui/#/cluster/fast-data-dev/topic/n/demo-twitter/

kafka-console-consumer --topic demo-twitter \
--from-beginning \
--bootstrap-server 127.0.0.1:9092

# open http://localhost:3030/kafka-connect-ui/#/cluster/fast-data-dev/create-connector/com.eneco.trading.kafka.connect.twitter.TwitterSourceConnector 
# and copypast configuration

# or by REST api from a new terminal
curl --location --request POST 'http://localhost:8083/connectors' \
--header 'Content-Type: application/json' \
--header 'Accept: application/json' \
--data-raw '{
  "name": "twitter-source",
  "config": {
    "connector.class": "com.eneco.trading.kafka.connect.twitter.TwitterSourceConnector",
    "tasks.max": "1",
    "topics": "demo-twitter",
    "topic": "demo-twitter",
    "twitter.consumerkey": "zMxyU3rnrDZYsN9GtQhvtzFU8",
    "twitter.consumersecret": "M78DxZ690iVYTMjVIm3IAtsixY97tYnrHcCK6ffleiSDhPTtcf",
    "twitter.token": "183760084-4eacEaGrI5r9OW0wi5NhACjQiKvHkb65DC8yfSt0",
    "twitter.secret": "YLMRTWHhsp7ZiS6iEUSzg2Al6CGqGFz1C2xtUMYCJ32WC",
    "track.terms": "clojure,consul,javascript",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true"
  }
}'

#after that request you should see data in consumer terminal


# by end you can delete topic
kafka-topics --delete --topic demo-twitter \
--zookeeper 127.0.0.1:2181
```
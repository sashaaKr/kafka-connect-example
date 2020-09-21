Prerequisites: [twitter connector](../../source/twitter/) should be up and running

```bash
docker-compose up
# to make sure that elastic is up and running visit: http://127.0.0.1:9200/
# now you can copy properties config and past it in connector ui
# or use REST API

curl -X POST \
  http://localhost:8083/connectors \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{
  "name": "sink-elastic-twitter-distributed",
  "config": {
    "connector.class": "io.confluent.connect.elasticsearch.ElasticsearchSinkConnector",
    "tasks.max": "2",
    "topics": "demo-twitter",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true",
    "connection.url": "http://elasticsearch:9200",
    "type.name": "kafka-connect",
    "key.ignore": "true"
  }
}'

# in order to validate that pipeline works visit: http://127.0.0.1:9200/_plugin/dejavu/
# select app name 'demo-twitter' and start browsing
```
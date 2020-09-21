Prerequisites: [twitter connector](../../source/twitter/) should be up and running

```bash
docker-compose up

curl -X POST \
  http://localhost:8083/connectors \
  -H 'Content-Type: application/json' \
  -H 'Accept: application/json' \
  -d '{
  "name": "sink-postgres-twitter-distributed",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",
    "topics": "demo-twitter",
    "key.converter": "org.apache.kafka.connect.json.JsonConverter",
    "key.converter.schemas.enable": "true",
    "value.converter": "org.apache.kafka.connect.json.JsonConverter",
    "value.converter.schemas.enable": "true",
    "connection.url": "jdbc:postgresql://postgres:5432/postgres",
    "connection.user": "postgres",
    "connection.password": "postgres",
    "insert.mode": "upsert",
    "pk.mode": "kafka",
    "pk.field": "__connect_topic,__connect_partition,__connect_offset",
    "fields.whitelist": "id,created_at,text,lang,is_retweet",
    "auto.create": "true",
    "auto.evolve": "true"
  }
}'
```
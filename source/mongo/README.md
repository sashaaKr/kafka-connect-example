Mongodb connector installation guide: 
https://docs.mongodb.com/kafka-connector/current/kafka-installation/

Download mongoDB connector from:
https://www.confluent.io/hub/mongodb/kafka-connect-mongodb

Copy downloaded content into `mongo-native-connector` folder

Following commands are part of image: https://github.com/lensesio/fast-data-dev#enable-additional-connectors

```bash
docker-compose up
# http://localhost:3030 to see that everything are running

# configure mongo cluster
docker-compose exec mongo1 /usr/bin/mongo --eval '''if (rs.status()["ok"] == 0) {
    rsconf = {
      _id : "rs0",
      members: [
        { _id : 0, host : "mongo1:27017", priority: 1.0 },
        { _id : 1, host : "mongo2:27017", priority: 0.5 },
        { _id : 2, host : "mongo3:27017", priority: 0.5 }
      ]
    };
    rs.initiate(rsconf);
}
rs.conf();'''
# now connection to mongo should be available on locolhost:27017


# create mongo source connector
curl -X POST -H "Content-Type: application/json" --data '
  {"name": "mongo-source",
   "config": {
     "tasks.max":"1",
     "connector.class":"com.mongodb.kafka.connect.MongoSourceConnector",
     "connection.uri":"mongodb://mongo1:27017,mongo2:27017,mongo3:27017",
     "topic.prefix":"mongo",
     "database":"test",
     "collection":"pageviews"
}}' http://localhost:8083/connectors -w "\n"


# now you can consume data from topic
docker run --rm -it --net=host lensesio/fast-data-dev bash
kafka-console-consumer --topic mongo.test.pageviews \
--from-beginning \
--bootstrap-server 127.0.0.1:9092
# make CRUD operations in db and get them in consumer
```

Inspiration of how create mongo cluster taken from: https://github.com/mongodb/mongo-kafka/blob/master/docker/run.sh
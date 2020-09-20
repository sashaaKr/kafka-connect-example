const BSON = require('bson');
const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'my-app',
  brokers: ['localhost:9092']
})

const consumer = kafka.consumer({ groupId: 'test-group' })

const run = async () => {
  await consumer.connect()
  await consumer.subscribe({ topic: 'mongo.test.pageviews', fromBeginning: true })

  await consumer.run({
    eachMessage: async ({ topic, partition, message }) => {
      console.log('topic: ', topic)
      console.log('partition: ', partition)
      console.log('offset: ', message.offset)
      console.log('value: ', message.value.toString())

      // const doc = BSON.deserialize(message.value);
      // console.log('doc:', doc);
    },
  })
}

run().catch(console.error)
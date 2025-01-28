# Kafka Playground

## Setup

1. Run Kafka using docker

```shell
docker run -d -p 9092:9092 \
  --name broker \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_PROCESS_ROLES=broker,controller \
  -e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://127.0.0.1:9092 \
  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
  -e KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS=0 \
  -e KAFKA_NUM_PARTITIONS=3 \
  apache/kafka:latest
```

2. Clone and install the project

```shell
git clone git@github.com:Catsuko/karafka_playground.git
cd karafka_playground
bundle
```

3. Create Kafka topics

```shell
bundle exec karafka topics reset
```

## Running the App

Our pretend requirements are:
- We track every time a user hits one of our web pages
- We want to store a record per user for their total hits
- We want to batch our database queries to avoid lock bottlenecks

To see how our app achieves this with Kafka, first produce some fake messages with the following rake task:

```shell
bundle exec rake producer:produce_views
```

Our application will batch these messages by consuming the `views` topic with the `BatchingConsumer`. This
consumer will continually count hits per user id for a period of time before writing
the totals into a `batched_views` topic.

This topic will be consumed by the `PretendDbConsumer` which will simulate a db query by printing the payload
of ids and counts it would update and then sleeping for a little while.

Run the consumers with the karafka gem and then watch the output to see this in action:

```shell
bundle exec karafka server
```

You can also start and stop multiple servers to see the fault tolerance and horizontal scaling work.

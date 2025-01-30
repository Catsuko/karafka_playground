# Kafka Playground

Play with Kafka & Ruby with the [Karafka gem](https://github.com/karafka/karafka). In this project, we build a program
that consumes a stream of user view data and aggregates it into total counts per user.

Our pretend requirements are:
- We want to store a record per user for their total hits
- We want to batch our database queries to avoid locking bottlenecks

These project is based on the talk
[Processing streaming data at scale with Kafka](https://www.youtube.com/watch?v=-NMDqqW1uCE) which gives the same
example scenario as a demonstration. The code used in that talk can be found
[here](https://github.com/appsignal/kafka-talk-demo/tree/master?tab=readme-ov-file) however I found it hard to run
that project given how old it is.

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

First produce some fake messages with the following rake task:

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

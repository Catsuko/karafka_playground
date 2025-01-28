# frozen_string_literal: true

ENV['KARAFKA_ENV'] ||= 'development'
Bundler.require(:default, ENV['KARAFKA_ENV'])

APP_LOADER = Zeitwerk::Loader.new
APP_LOADER.enable_reloading

%w[
  lib
  app/consumers
].each { |dir| APP_LOADER.push_dir(dir) }

APP_LOADER.setup
APP_LOADER.eager_load

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': '127.0.0.1:9092' }
    config.client_id = 'example_app'
    config.concurrency = 4
  end

  Karafka.monitor.subscribe(
    Karafka::Instrumentation::LoggerListener.new(log_polling: false)
  )
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(Karafka.logger, log_messages: false)
  )

  routes.draw do
      topic :views do
        config(partitions: 5, 'cleanup.policy': 'delete')
        consumer BatchingConsumer
      end
      topic :batched_views do
        config(partitions: 5, 'cleanup.policy': 'delete')
        consumer PretendDbConsumer
      end
  end
end

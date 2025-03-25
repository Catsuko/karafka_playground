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

$results = Hash.new(0)

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': '127.0.0.1:9092' }
    config.client_id = 'example_app'
    config.concurrency = 4
  end

  Karafka.monitor.subscribe(
    Karafka::Instrumentation::LoggerListener.new(log_polling: false)
  )
  Karafka.monitor.subscribe 'app.stopped' do |_event|
    total_queries = $results.delete(:total_queries).to_i
    puts <<~RESULTS

    🏁 Results 🏁

    #{$results.keys.sort.map { |id| "#{id.to_s.ljust(2)}: #{$results.fetch(id)}" }.join("\n") }

    Totals
      Users:   #{$results.keys.size}
      Views:   #{$results.values.sum}
      Queries: #{total_queries}

    RESULTS
  end
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(Karafka.logger, log_messages: false)
  )

  routes.draw do
      topic :raw_views do
        config(partitions: 3, 'cleanup.policy': 'delete')
        consumer BatchingConsumer
      end
      topic :views do
        config(partitions: 3, 'cleanup.policy': 'delete')
        consumer UpdateViewCountsConsumer
      end
  end
end

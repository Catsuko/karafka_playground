namespace :producer do
  task :produce_views, [:topic] do |_t, args|
    at_exit do
      ::Karafka.producer.close
    end
    topic = args.fetch(:topic, 'views')
    rng = Random.new(1)

    5_000.times do
      user_id = rng.rand(1..15)
      ::Karafka.producer.produce_async(
        topic: topic,
        payload: { id: user_id, count: 1 }.to_json,
        key: user_id.to_s
      )
    end
  end
end

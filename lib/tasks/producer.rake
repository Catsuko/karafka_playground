namespace :producer do
  task :produce_views, [:topic] do |_t, args|
    total_views = 0
    at_exit do
      puts "Produced #{total_views} messages"
      ::Karafka.producer.close
    end
    topic = args.fetch(:topic, 'views')

    loop do
      user_id = rand(1..50).to_s
      ::Karafka.producer.produce_async(
        topic: topic,
        payload: { id: user_id, count: 1 }.to_json,
        key: user_id
      )
      total_views += 1
    end
  end
end

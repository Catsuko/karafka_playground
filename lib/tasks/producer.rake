namespace :producer do
  task :produce_views do
    at_exit { ::Karafka.producer.close }

    loop do
      user_id = rand(1..50)
      ::Karafka.producer.produce_async(
        topic: 'views',
        payload: { id: user_id }.to_json,
        key: user_id.to_s
      )
    end
  end
end

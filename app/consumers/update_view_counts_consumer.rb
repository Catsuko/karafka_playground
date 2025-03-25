# frozen_string_literal: true

# Uses the power of imagination to
# perform slow db updates.
class UpdateViewCountsConsumer < ApplicationConsumer
  def consume
    views = messages.payloads.each_with_object(Hash.new(0)) { |entry, hash| hash[entry["id"]] += entry["count"] }
    puts "Updating: #{views.inspect}"

    update_db(views)
    add_to_global_results(views)
  end

  def update_db(views)
    sleep rand
  end

  def add_to_global_results(views)
    views.each { |id, count| $results[id] += count }
    $results[:total_queries] += 1
  end
end

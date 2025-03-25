# frozen_string_literal: true

# Uses the power of imagination to
# perform slow db updates.
class UpdateViewCountsConsumer < ApplicationConsumer
  def consume
    update_view_counts(messages.payloads)
  end

  def update_view_counts(views)
    update_query = views.each_with_object(Hash.new(0)) { |entry, hash| hash[entry["id"]] += entry["count"] }
    puts "Update DB: #{update_query.inspect}"
    sleep rand
  end
end

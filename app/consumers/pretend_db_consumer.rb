# frozen_string_literal: true

# Uses the power of imagination to
# perform slow db updates.
class PretendDbConsumer < ApplicationConsumer
  def consume
    puts "DB Query with: #{messages.payloads.inspect}"
    sleep rand(1..5)
  end
end

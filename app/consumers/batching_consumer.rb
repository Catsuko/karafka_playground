# frozen_string_literal

# Consumes and aggregates user view data into a new topic
# so view data can be processed efficiently.
#
# For example:
#
#   { 'id' => 1 }
#   { 'id' => 1 }
#   { 'id' => 2 }
#   { 'id' => 1 }
#
# Will become:
#
#   { 'id' => 1, 'count' => 3 }
#   { 'id' => 2, 'count' => 1 }
#

class BatchingConsumer < ApplicationConsumer
  def initialize(group_by: 'id', receiver: 'batched_views')
    @buffer = Hash.new(0)
    @group_by = group_by
    @receiver = receiver
  end

  def consume
    messages.each { |message| @buffer[message.payload.fetch(@group_by)] += 1 }
    when_ready_to_commit { flush_to_topic }
  end

  private

  def when_ready_to_commit(tick: 5)
    time = Time.now.to_i
    @committed_at ||= time

    if @committed_at + tick > time
      @committed_at = nil
      yield
    end
  end

  def flush_to_topic
    return if @buffer.empty?

    batched_messages = @buffer.map do |id, count|
      { topic: @receiver, key: id.to_s, payload: { id: id, count: count }.to_json }
    end

    ::Karafka.producer.produce_many_async(batched_messages)
    @buffer.clear
  end
end
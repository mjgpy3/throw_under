class QueueBinder

  def initialize(configurator)
    connection = Bunny.new(configurator.rabbit_url)
    @channel = connection.start.create_channel
    @queue = @channel.queue("#.#{configurator.routing_suffix}")
  end

  def bind_queues
    @queue.subscribe
  end

end

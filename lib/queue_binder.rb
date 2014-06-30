class QueueBinder

  def initialize(configurator)
    connection = Bunny.new(configurator.rabbit_url)
    @channel = connection.start.create_channel
    @fanout = @channel.fanout("#.#{configurator.routing_suffix}")
  end

  def bind_queues
    @channel.queue('throw_under', auto_delete: true).bind(@fanout)
  end

end

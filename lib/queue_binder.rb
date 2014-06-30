class QueueBinder

  def initialize(configurator)
    connection = Bunny.new(configurator.rabbit_url)
    channel = connection.start.create_channel
    channel.fanout(configurator.routing_suffix)
  end

end

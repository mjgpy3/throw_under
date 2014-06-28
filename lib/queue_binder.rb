class QueueBinder

  def initialize(configurator)
    connection = Bunny.new(configurator.rabbit_url)
    connection.start.create_channel
  end

end

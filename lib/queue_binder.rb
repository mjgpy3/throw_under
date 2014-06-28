class QueueBinder

  def initialize(configurator)
    Bunny.new(configurator.rabbit_url)
  end

end

class Configurator

  MUST_SPECIFY_OUTBOUND = 'Must specify outbound queue for each inbound'
  MUST_SPECIFY_INBOUND = 'Must specify inbound queue for each outbound'
  MUST_SPECIFY_TYPE = 'Messages must each have a type'
  MISSING_ROUTING_SUFFIX = 'Must specify a routing suffix'
  LISTENERS_MUST_BE_QUEUES = 'All listeners must be outbound queues'

  def initialize(file_name)
    config_path = File.expand_path("../../config/#{file_name}", __FILE__)
    @config = YAML.load_file(config_path)
  end

  def validate
    validate_routing_suffix
    validate_queues
    validate_messages
    self
  end

  def rabbit_url
    rabbit = @config['rabbitmq']
    "#{rabbit['protocol']}://#{rabbit['username']}:#{rabbit['password']}@#{rabbit['host']}:#{rabbit['port']}"
  end

  def messages
    @config['messages']
  end

  def queues
    @config['queues']
  end

  def routing_suffix
    @config['routing_suffix']
  end

  private

  def validate_routing_suffix
    fail MISSING_ROUTING_SUFFIX unless @config.include?('routing_suffix')
  end

  def validate_messages
    return if messages.nil?

    fail MUST_SPECIFY_TYPE if any_messages_neglect_type?
    fail LISTENERS_MUST_BE_QUEUES if any_listeners_are_not_outbound_queries?
  end

  def any_messages_neglect_type?
    messages.any? { |m| !m.include?('type') }
  end

  def any_listeners_are_not_outbound_queries?
    listeners.any? { |l| !outbound_queues.include?(l) }
  end

  def validate_queues
    return if queues.nil?

    queues.each do |queue|
      fail error_for_missing(queue) if queue_missing?(queue)
    end
  end

  def has_inbound_suffix?(queue)
    queue['inbound'].end_with?('.route_me')
  end

  def outbound_queues
    queues.
      map { |q| q['outbound'] }.
      select { |q| q }
  end

  def listeners
    messages.
      map { |m| m['listeners'] }.
      flatten.
      select { |q| q }
  end

  def queue_missing?(queue)
    queue.count == 1
  end

  def error_for_missing(queue)
    queue['inbound'].nil? ? MUST_SPECIFY_INBOUND : MUST_SPECIFY_OUTBOUND
  end

end

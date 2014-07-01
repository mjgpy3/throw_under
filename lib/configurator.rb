class Configurator

  MUST_SPECIFY_TYPE = 'Messages must each have a type'
  MISSING_ROUTING_SUFFIX = 'Must specify a routing suffix'

  def initialize(file_name)
    config_path = File.expand_path("../../config/#{file_name}", __FILE__)
    @config = YAML.load_file(config_path)
  end

  def validate
    validate_routing_suffix
    validate_messages
    self
  end

  def rabbit_url
    rabbit = @config['rabbitmq']
    "#{rabbit['protocol']}://#{rabbit['username']}:#{rabbit['password']}@#{rabbit['host']}:#{rabbit['port']}"
  end

  ['messages', 'queues', 'routing_suffix'].each do |config_value|
    define_method(config_value) do
      @config[config_value]
    end
  end

  private

  def validate_routing_suffix
    fail MISSING_ROUTING_SUFFIX unless @config.include?('routing_suffix')
  end

  def validate_messages
    return if messages.nil?

    fail MUST_SPECIFY_TYPE if any_messages_neglect_type?
  end

  def any_messages_neglect_type?
    messages.any? { |m| !m.include?('type') }
  end

  def listeners
    messages.
      map { |m| m['listeners'] }.
      flatten.
      select { |q| q }
  end

end

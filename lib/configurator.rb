class Configurator

  MUST_SPECIFY_OUTBOUND = 'Must specify outbound queue for each inbound'
  MUST_SPECIFY_INBOUND = 'Must specify inbound queue for each outbound'
  MUST_SPECIFY_TYPE = 'Messages must each have a type'
  LISTENERS_MUST_BE_QUEUES = 'All listeners must be outbound queues'

  def initialize(file_name)
    config_path = File.expand_path("../../config/#{file_name}", __FILE__)
    @config = YAML.load_file(config_path)
  end

  def validate
    validate_queues
    validate_messages
    self
  end

  private

  def validate_messages
    return if messages.nil?

    fail MUST_SPECIFY_TYPE if messages.any? { |m| !m.include?('type') }
    outbound_queues = queues ? queues.
      map { |q| q['outbound'] }.
      select { |q| q } : []

    listeners = messages.map { |m| m['listeners'] }.flatten.select { |q| q }

    listeners.each do |listener|
      fail LISTENERS_MUST_BE_QUEUES unless outbound_queues.include?(listener)
    end
  end

  def validate_queues
    return if queues.nil?

    queues.each do |queue|
      fail error_for_missing(queue) if queue_missing?(queue)
    end
  end

  def queue_missing?(queue)
    queue.count == 1
  end

  def error_for_missing(queue)
    queue['inbound'].nil? ? MUST_SPECIFY_INBOUND : MUST_SPECIFY_OUTBOUND
  end

  def queues
    @config['queues']
  end

  def messages
    @config['messages']
  end

end

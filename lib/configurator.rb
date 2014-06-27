class Configurator

  def initialize(file_name)
    config_path = File.expand_path("../config/#{file_name}", __FILE__)
    YAML.load_file(config_path)
  end

end

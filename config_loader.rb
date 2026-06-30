require 'yaml'

class ConfigLoader
  def initialize(config_path: "config.yml")
    @config_path = config_path
  end

  def load
    return default_config unless File.exist?(@config_path)
    data = YAML.load_file(@config_path)
  end

  # make a default config file and make a hash for it for the file path and min_length
end

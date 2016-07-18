require 'rhea'

Rhea.configure do |config|
  config_path = Rails.root.join('config/rhea.yml')
  config_hash = YAML.load(File.read(config_path))
  config_hash.deep_symbolize_keys!
  config_hash.each do |key, value|
    config.public_send("#{key}=", value)
  end
end

module Rhea
  class Configuration
    attr_accessor :default_command_type_key, :env_vars, :image, :kube_api

    def initialize
      self.default_command_type_key = 'default'
      self.env_vars = {}
      self.image = nil
      self.kube_api = {}
    end
  end
end

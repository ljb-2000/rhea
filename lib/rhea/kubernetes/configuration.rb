module Rhea
  class Configuration
    attr_accessor :command_types, :container_options, :default_command_type_key, :default_image, :env_vars, :kube_api

    def initialize
      self.command_types = [
        {
          key: 'default',
          name: 'Default',
          format: '$INPUT'
        },
        {
          key: 'resque',
          name: 'Resque',
          format: 'QUEUES=$INPUT rake resque:work'
        },
        {
          key: 'sidekiq',
          name: 'Sidekiq',
          format: 'bundle exec sidekiq $INPUT'
        }
      ]
      self.container_options = {}
      self.default_command_type_key = 'default'
      self.default_image = nil
      self.env_vars = {}
      self.kube_api = {}
    end
  end
end

module Rhea
  module Kubernetes
    module Commands
      class Scale < Base
        attr_accessor :command

        def initialize(command_attributes)
          self.command = Command.new(command_attributes)
        end

        def perform
          if is_replication_controller_running?
            scale_replication_controller
          else
            start_replication_controller
          end
        end

        private

        def is_replication_controller_running?
          api.get_replication_controllers(label_selector: "name=#{command.key}").length > 0
        end

        def start_replication_controller
          parsed_command_expression = parse_command_expression
          raw_command_expression = parsed_command_expression[:raw_command_expression]
          env_vars = parsed_command_expression[:env_vars]
          formatted_env_vars = format_env_vars(env_vars)

          controller = Kubeclient::ReplicationController.new
          controller.metadata = {
            'name' => command.key,
            'namespace' => NAMESPACE,
            'labels' => {
              'name' => command.key
            },
            'annotations' => {
              'rhea_command' => command.expression
            }
          }
          controller.spec = {
            'replicas' => command.process_count,
            'selector' => {
              'name' => command.key
            },
            'template' => {
              'metadata' => {
                'labels' => {
                  'name' => command.key
                },
                'annotations' => {
                  'rhea_command' => command.expression
                }
              },
              'spec' => {
                'containers' => [
                  {
                    'name' => command.key,
                    'image' => command.image,
                    'env' => formatted_env_vars,
                    'command' => raw_command_expression.split(/\s+/)
                  }
                ]
              }
            }
          }
          api.create_replication_controller(controller)
        end

        def scale_replication_controller
          controller = api.get_replication_controllers(label_selector: "name=#{command.key}").first
          controller.spec.replicas = command.process_count
          api.update_replication_controller(controller)
        end

        def parse_command_expression
          match = command.expression.match(/((?:[A-Z]+=[^\s]+\s+)+)?(.+)/)
          env_vars_string = match[1]
          raw_command_expression = match[2]
          env_vars = {}
          if env_vars_string.present?
            env_vars_strings = env_vars_string.strip.split(/\s+/)
            env_vars_strings.each do |string|
              name, value = string.split('=')
              env_vars[name] = value
            end
          end
          {
            raw_command_expression: raw_command_expression,
            env_vars: env_vars
          }
        end

        def format_env_vars(env_vars)
          hash = env_vars.merge(Rhea.configuration.env_vars)
          hash.map do |name, value|
            {
              'name' => name,
              'value' => value
            }
          end
        end
      end
    end
  end
end

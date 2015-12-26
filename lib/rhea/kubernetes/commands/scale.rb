module Rhea
  module Kubernetes
    module Commands
      class Scale < Base
        attr_accessor :command_expression, :process_count, :image

        def initialize(command_expression, process_count, image: nil)
          self.command_expression = command_expression
          self.process_count = process_count
          self.image = image || Rhea.configuration.image
        end

        def perform
          key = command_expression_to_key(command_expression)
          if is_replication_controller_running?(key)
            scale_replication_controller(command_expression, process_count)
          else
            start_replication_controller(command_expression, process_count)
          end
        end

        private

        def is_replication_controller_running?(key)
          api.get_replication_controllers(label_selector: "name=#{key}").length > 0
        end

        def start_replication_controller(command_expression, process_count)
          key = command_expression_to_key(command_expression)
          parsed_command_expression = parse_command_expression(command_expression)
          raw_command_expression = parsed_command_expression[:raw_command_expression]
          env_vars = parsed_command_expression[:env_vars]
          formatted_env_vars = format_env_vars(env_vars)

          controller = Kubeclient::ReplicationController.new
          controller.metadata = {
            'name' => key,
            'namespace' => NAMESPACE,
            'labels' => {
              'name' => key
            },
            'annotations' => {
              'rhea_command' => command_expression
            }
          }
          controller.spec = {
            'replicas' => process_count,
            'selector' => {
              'name' => key
            },
            'template' => {
              'metadata' => {
                'labels' => {
                  'name' => key
                },
                'annotations' => {
                  'rhea_command' => command_expression
                }
              },
              'spec' => {
                'containers' => [
                  {
                    'name' => key,
                    'image' => image,
                    'env' => formatted_env_vars,
                    'command' => raw_command_expression.split(/\s+/)
                  }
                ]
              }
            }
          }
          api.create_replication_controller(controller)
        end

        def scale_replication_controller(command_expression, process_count)
          key = command_expression_to_key(command_expression)
          controller = api.get_replication_controllers(label_selector: "name=#{key}").first
          controller.spec.replicas = process_count
          api.update_replication_controller(controller)
        end

        def parse_command_expression(command_expression)
          match = command_expression.match(/((?:[A-Z]+=[^\s]+\s+)+)?(.+)/)
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

module Rhea
  module Kubernetes
    module Commands
      class Scale < Base
        attr_accessor :command, :process_count

        def initialize(command, process_count)
          self.command = command
          self.process_count = process_count
        end

        def perform
          key = command_to_key(command)
          if is_replication_controller_running?(key)
            scale_replication_controller(command, process_count)
          else
            start_replication_controller(command, process_count)
          end
        end

        private

        def is_replication_controller_running?(key)
          api.get_replication_controllers(label_selector: "name=#{key}").length > 0
        end

        def start_replication_controller(command, process_count)
          key = command_to_key(command)
          parsed_command = parse_command(command)
          raw_command = parsed_command[:raw_command]
          env_vars = parsed_command[:env_vars]
          formatted_env_vars = format_env_vars(env_vars)

          controller = Kubeclient::ReplicationController.new
          controller.metadata = {
            'name' => key,
            'namespace' => NAMESPACE,
            'labels' => {
              'name' => key
            },
            'annotations' => {
              'rhea_command' => command
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
                  'rhea_command' => command
                }
              },
              'spec' => {
                'containers' => [
                  {
                    'name' => key,
                    'image' => Rhea.settings[:image],
                    'env' => formatted_env_vars,
                    'command' => raw_command.split(/\s+/)
                  }
                ]
              }
            }
          }
          api.create_replication_controller(controller)
        end

        def scale_replication_controller(command, process_count)
          key = command_to_key(command)
          controller = api.get_replication_controllers(label_selector: "name=#{key}").first
          controller.spec.replicas = process_count
          api.update_replication_controller(controller)
        end

        def parse_command(command)
          match = command.match(/((?:[A-Z]+=[^\s]+\s+)+)?(.+)/)
          env_vars_string = match[1]
          raw_command = match[2]
          env_vars = {}
          if env_vars_string.present?
            env_vars_strings = env_vars_string.strip.split(/\s+/)
            env_vars_strings.each do |string|
              name, value = string.split('=')
              env_vars[name] = value
            end
          end
          {
            raw_command: raw_command,
            env_vars: env_vars
          }
        end

        def format_env_vars(env_vars)
          hash = env_vars.merge(Rhea.settings[:env_vars])
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

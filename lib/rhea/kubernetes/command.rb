module Rhea
  module Kubernetes
    class Command
      NAMESPACE = 'default'

      class << self
        def scale(command, process_count)
          key = command_to_key(command)
          if is_replica_controller_running?(key)
            scale_replica_controller(command, process_count)
          else
            start_replica_controller(command, process_count)
          end
        end

        def destroy(command)
          delete_replica_controller(command)
        end

        def all
          controllers = api.get_replication_controllers
          commands = controllers.map do |controller|
            expression = controller.spec.template.metadata.annotations.try(:rhea_command)
            next if expression.nil?
            process_count = controller.status.replicas
            image = controller.spec.template.spec.containers.first.image.split('/').last
            OpenStruct.new(
              expression: expression,
              image: image,
              process_count: process_count
            )
          end.compact
          commands = commands.sort_by(&:expression)
          commands
        end

        private

        def api
          @api ||= Rhea::Kubernetes::Api.new
        end

        def command_to_key(command)
          image = Rhea.settings[:image]
          command_hash = Digest::MD5.hexdigest("#{image}#{command}")[0..3]
          command_for_host = command.downcase.gsub(/[^-a-z0-9]+/i, '-').squeeze('-')
          key = "#{key_prefix}#{command_hash}-#{command_for_host}"
          max_host_name_length = 64
          key = key[0,max_host_name_length]
          # The key can't end with a '-'
          key.gsub!(/\-+$/, '')
          key
        end

        def is_replica_controller_running?(key)
          api.get_replication_controllers(label_selector: "name=#{key}").length > 0
        end

        def delete_replica_controller(command)
          # NOTE: Deleting the rc sends a kill signal that doesn't gracefully stop Resque worker processes.
          key = command_to_key(command)
          api.delete_replication_controller(key, NAMESPACE)
        end

        def start_replica_controller(command, process_count)
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

        def scale_replica_controller(command, process_count)
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

        def key_prefix
          'rhea-'
        end
      end
    end
  end
end

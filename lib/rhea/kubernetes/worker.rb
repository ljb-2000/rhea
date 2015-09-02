module Rhea
  module Kubernetes
    class Worker
      class << self
        def scale(queue_identifier, workers_count)
          key = queue_identifier_to_key(queue_identifier)
          if workers_count == 0
            delete_replica(queue_identifier)
            return
          end
          if is_replica_running?(key)
            scale_replica(queue_identifier, workers_count)
          else
            start_replica(queue_identifier, workers_count)
          end
        end

        def queue_identifiers_workers_counts
          controllers = api.get_replication_controllers
          queue_identifiers_workers_counts = controllers.map do |controller|
            queue_identifier = controller.spec.template.metadata.annotations.try(:rhea_queue_identifier)
            next(nil) if queue_identifier.nil?
            workers_count = controller.status.replicas
            [queue_identifier, workers_count]
          end.compact
          queue_identifiers_workers_counts = queue_identifiers_workers_counts.sort_by(&:first)
          Hash[queue_identifiers_workers_counts]
        end

        private

        def api
          @api ||= Rhea::Kubernetes::Api.new
        end

        def queue_identifier_to_key(queue_identifier)
          queue_hash = Digest::MD5.hexdigest(queue_identifier)[0..3]
          queue_identifier_for_host = queue_identifier.gsub(/[^-a-z0-9]+/i, '-')
          key = "#{key_prefix}#{queue_hash}-#{queue_identifier_for_host}"
          max_host_name_length = 64
          key = key[0,max_host_name_length]
          key
        end

        def is_replica_running?(key)
          api.get_replication_controllers(label_selector: "name=#{key}").length > 0
        end

        def delete_replica(queue_identifier)
          key = queue_identifier_to_key(queue_identifier)
          scale_replica(queue_identifier, 0)
          # TODO: We should delete the RC instead of scaling it to 0, but deleting it
          # sends a kill signal that doesn't gracefully stop Resque worker processes.
          # binding.pry
          # api.delete_replication_controller(key)
        end

        def start_replica(queue_identifier, workers_count)
          key = queue_identifier_to_key(queue_identifier)
          controller = Kubeclient::ReplicationController.new
          controller.metadata = {
            "name" => key,
            "namespace" => 'default',
            "labels" => {
              "name" => key
            },
            "annotations" => {
              "rhea_queue_identifier" => queue_identifier
            }
          }
          controller.spec = {
            "replicas" => workers_count,
            "selector" => {
              "name" => key
            },
            "template" => {
              "metadata" => {
                "labels" => {
                  "name" => key
                },
                "annotations" => {
                  "rhea_queue_identifier" => queue_identifier
                }
              },
              "spec" => {
                "containers" => [
                  {
                    "name" => key,
                    "image" => Rhea.settings[:image],
                    "env" => get_env_vars(queue_identifier)
                  }
                ],
                "imagePullSecrets" => [
                  {
                    "name" => "myregistrykey"
                  }
                ]
              }
            }
          }
          api.create_replication_controller(controller)
        end

        def scale_replica(queue_identifier, workers_count)
          key = queue_identifier_to_key(queue_identifier)
          controller = api.get_replication_controllers(label_selector: "name=#{key}").first
          controller.spec.replicas = workers_count
          api.update_replication_controller(controller)
        end

        def get_env_vars(queue_identifier)
          defaults = {
            'QUEUE' => queue_identifier
          }
          hash = defaults.merge(Rhea.settings[:env_vars])
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

module Rhea
  module Kubernetes
    module Commands
      class Base
        NAMESPACE = 'default'

        private

        def api
          @api ||= Rhea::Kubernetes::Api.new
        end

        def command_expression_to_key(command_expression)
          image = Rhea.configuration.image
          command_hash = Digest::MD5.hexdigest("#{image}#{command_expression}")[0..3]
          command_for_host = command_expression.downcase.gsub(/[^-a-z0-9]+/i, '-').squeeze('-')
          key = "#{key_prefix}#{command_hash}-#{command_for_host}"
          max_host_name_length = 62
          key = key[0,max_host_name_length]
          # The key can't end with a '-'
          key.gsub!(/\-+$/, '')
          key
        end

        def controller_to_command(controller)
          expression = controller.spec.template.metadata.annotations.try(:rhea_command)
          return if expression.nil?
          process_count = controller.status.replicas
          image = controller.spec.template.spec.containers.first.image
          Command.new(
            expression: expression,
            image: image,
            process_count: process_count,
            created_at: Time.parse(controller.metadata.creationTimestamp)
          )
        end

        def key_prefix
          'rhea-'
        end
      end
    end
  end
end

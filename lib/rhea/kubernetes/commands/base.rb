module Rhea
  module Kubernetes
    module Commands
      class Base
        NAMESPACE = 'default'

        private

        def api
          @api ||= Rhea::Kubernetes::Api.new
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
      end
    end
  end
end

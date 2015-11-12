module Rhea
  module Kubernetes
    module Commands
      class All < Base
        def perform
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
      end
    end
  end
end

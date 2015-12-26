module Rhea
  module Kubernetes
    module Commands
      class All < Base
        def perform
          controllers = api.get_replication_controllers
          commands = controllers.map do |controller|
            controller_to_command(controller)
          end.compact
          commands = commands.sort_by(&:expression)
          commands
        end
      end
    end
  end
end

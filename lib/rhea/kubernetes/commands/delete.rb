module Rhea
  module Kubernetes
    module Commands
      class Delete < Base
        attr_accessor :command_expression

        def initialize(command_expression)
          self.command_expression = command_expression
        end

        def perform
          key = command_expression_to_key(command_expression)
          # NOTE: Deleting the rc sends a kill signal that doesn't gracefully stop Resque worker processes.
          api.delete_replication_controller(key, NAMESPACE)
        end
      end
    end
  end
end

module Rhea
  module Kubernetes
    module Commands
      class Delete < Base
        attr_accessor :command

        def initialize(command_attributes)
          self.command = Command.new(command_attributes)
        end

        def perform
          # NOTE: Deleting the rc sends a kill signal that doesn't gracefully stop Resque worker processes.
          api.delete_replication_controller(command.key, NAMESPACE)
        end
      end
    end
  end
end

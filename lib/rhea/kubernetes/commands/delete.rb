module Rhea
  module Kubernetes
    module Commands
      class Delete < Base
        attr_accessor :command

        def initialize(command)
          self.command = command
        end

        def perform
          key = command_to_key(command)
          # NOTE: Deleting the rc sends a kill signal that doesn't gracefully stop Resque worker processes.
          api.delete_replication_controller(key, NAMESPACE)
        end
      end
    end
  end
end

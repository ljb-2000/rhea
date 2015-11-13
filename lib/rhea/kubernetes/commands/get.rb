module Rhea
  module Kubernetes
    module Commands
      class Get < Base
        attr_accessor :command

        def initialize(command)
          self.command = command
        end

        def perform
          key = command_to_key(command)
          controller = api.get_replication_controllers(label_selector: "name=#{key}").first
          normalize_controller(controller)
        end
      end
    end
  end
end

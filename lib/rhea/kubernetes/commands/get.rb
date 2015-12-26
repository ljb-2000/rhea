module Rhea
  module Kubernetes
    module Commands
      class Get < Base
        attr_accessor :command

        def initialize(command_attributes)
          self.command = Command.new(command_attributes)
        end

        def perform
          controller = api.get_replication_controllers(label_selector: "name=#{command.key}").first
          controller_to_command(controller)
        end
      end
    end
  end
end

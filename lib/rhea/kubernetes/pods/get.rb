# Get pods running a command (associated with a ReplicationController)
module Rhea
  module Kubernetes
    module Pods
      class Get
        attr_accessor :command

        def initialize(command_attributes)
          self.command = Command.new(command_attributes)
        end

        def perform
          api = Rhea::Kubernetes::Api.new
          api.get_pods(label_selector: "name=#{command.key}")
        end
      end
    end
  end
end

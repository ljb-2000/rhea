module Rhea
  module Kubernetes
    module Commands
      class Get < Base
        attr_accessor :command_expression

        def initialize(command_expression)
          self.command_expression = command_expression
        end

        def perform
          key = command_expression_to_key(command_expression)
          controller = api.get_replication_controllers(label_selector: "name=#{key}").first
          controller_to_command(controller)
        end
      end
    end
  end
end

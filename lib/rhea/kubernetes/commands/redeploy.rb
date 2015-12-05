module Rhea
  module Kubernetes
    module Commands
      class Redeploy < Base
        attr_accessor :command_expression

        def initialize(command_expression)
          self.command_expression = command_expression
        end

        def perform
          controller = Get.new(command_expression).perform
          process_count = controller.process_count
          Scale.new(command_expression, 0).perform
          Delete.new(command_expression).perform
          Scale.new(command_expression, process_count).perform
        end
      end
    end
  end
end

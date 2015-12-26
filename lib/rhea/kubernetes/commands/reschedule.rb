module Rhea
  module Kubernetes
    module Commands
      class Reschedule < Base
        attr_accessor :command

        def initialize(command_attributes)
          self.command = Command.new(command_attributes)
        end

        def perform
          command_attributes = command.attributes.slice(:image, :expression)
          controller = Get.new(command_attributes).perform
          process_count = controller.process_count
          Scale.new(command_attributes.merge(process_count: 0)).perform
          Scale.new(command_attributes.merge(process_count: process_count)).perform
        end
      end
    end
  end
end

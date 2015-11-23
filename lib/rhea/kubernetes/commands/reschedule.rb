module Rhea
  module Kubernetes
    module Commands
      class Reschedule < Base
        attr_accessor :command

        def initialize(command)
          self.command = command
        end

        def perform
          controller = Get.new(command).perform
          process_count = controller.process_count
          Scale.new(command, 0).perform
          Scale.new(command, process_count).perform
        end
      end
    end
  end
end

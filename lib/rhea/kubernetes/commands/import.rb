module Rhea
  module Kubernetes
    module Commands
      class Import < Base
        attr_accessor :data

        def initialize(data)
          self.data = data
        end

        def perform
          commands_data = data['commands']
          commands_data.each do |command_data|
            Scale.new(command_data['expression'], command_data['process_count'], image: command_data['image']).perform
          end
        end
      end
    end
  end
end

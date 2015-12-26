module Rhea
  module Kubernetes
    module Commands
      class Export < Base
        def perform
          commands = All.new.perform
          commands_data = commands.map do |command|
            {
              expression: command.expression,
              image: command.image,
              process_count: command.process_count
            }
          end
          {
            version: Rhea::VERSION,
            created_at: Time.now.utc,
            commands: commands_data
          }
        end
      end
    end
  end
end

module Rhea
  class CommandType
    attr_accessor :key, :name, :format

    COMMAND_TYPES = [
      {
        key: 'default',
        name: 'Default',
        format: '$INPUT'
      },
      {
        key: 'resque',
        name: 'Resque',
        format: 'QUEUES=$INPUT rake resque:work'
      },
      {
        key: 'sidekiq',
        name: 'Sidekiq',
        format: 'bundle exec sidekiq $INPUT'
      }
    ]

    def initialize(key:, name:, format:)
      self.key = key
      self.name = name
      self.format = format
    end

    def input_to_command_expression(input)
      format.gsub('$INPUT', input)
    end

    def displayed_format
      format.gsub('$INPUT', '$input')
    end

    class << self
      def all
        @all ||= COMMAND_TYPES.map do |attributes|
          new(attributes)
        end
      end

      def find(key)
        command_type = all.find { |command_type| command_type.key == key }
        raise "Invalid key: #{key}" unless command_type
        command_type
      end

      def options_for_select
        all.map { |command_type| [command_type.name, command_type.key] }
      end
    end
  end
end

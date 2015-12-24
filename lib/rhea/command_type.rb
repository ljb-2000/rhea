module Rhea
  class CommandType
    attr_accessor :key, :name, :format

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

    def self.all
      @all ||= Rhea.configuration.command_types.map do |attributes|
        new(attributes)
      end
    end

    def self.find(key)
      command_type = all.find { |command_type| command_type.key == key }
      raise "Invalid key: #{key}" unless command_type
      command_type
    end

    def self.options_for_select
      all.map { |command_type| [command_type.name, command_type.key] }
    end
  end
end

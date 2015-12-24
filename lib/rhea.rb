require 'kubeclient'
require 'ostruct'

directory = File.dirname(File.absolute_path(__FILE__))
require "#{directory}/rhea/kubernetes/commands/base"
Dir.glob("#{directory}/rhea/**/*.rb") { |file| require file }

module Rhea
  module_function

  def self.configure
    yield(configuration) if block_given?
  end

  def self.configuration
    @configuration ||= Configuration.new
  end
end

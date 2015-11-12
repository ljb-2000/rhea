require 'kubeclient'
require 'ostruct'

directory = File.dirname(File.absolute_path(__FILE__))
require "#{directory}/rhea/kubernetes/commands/base"
Dir.glob("#{directory}/rhea/**/*.rb") { |file| require file }

module Rhea
  @settings = {
    default_command_type_key: 'default',
    env_vars: {},
    image: nil,
    kube_api: {}
  }

  def self.settings
    @settings
  end
end

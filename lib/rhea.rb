require 'kubeclient'
require 'ostruct'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/rhea/*.rb") { |file| require file }
Dir.glob("#{directory}/rhea/kubernetes/*.rb") { |file| require file }
Dir.glob("#{directory}/rhea/resque/*.rb") { |file| require file }

module Rhea
  @settings = {
    env_vars: {},
    image: nil,
    kube_api: {}
  }

  def self.settings
    @settings
  end
end

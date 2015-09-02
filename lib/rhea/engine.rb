require 'haml'
require 'sass-rails'

module Rhea
  class Engine < ::Rails::Engine
    isolate_namespace Rhea

    initializer "rhea.asset_pipeline" do |app|
      app.config.assets.precompile << 'rhea/application.js'
    end
  end
end

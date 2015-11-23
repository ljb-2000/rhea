module Rhea
  class ServicesController < Rhea::BaseController
    def index
      @services = Rhea::Kubernetes::Service.names_paths
    end
  end
end

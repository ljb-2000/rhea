module Rhea
  class SystemServicesController < Rhea::BaseController
    def index
      @service_names_urls = Rhea::Kubernetes::SystemServices.service_names_urls
    end
  end
end

module Rhea
  class ServicesController < Rhea::BaseController
    def index
      services_url = "#{Rhea.settings[:kube_api][:url]}v1/proxy/namespaces/kube-system/services/"
      @services = {
        'Kubernetes UI' => "#{services_url}kube-ui/",
        'Grafana' => "#{services_url}monitoring-grafana/"
      }
    end
  end
end

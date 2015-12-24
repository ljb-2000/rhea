module Rhea
  module Kubernetes
    module SystemServices
      module_function

      def service_names_urls
        @service_names_urls ||= begin
          api_url = Rhea.configuration.kube_api[:url]
          root_url = api_url.sub('/api/', '/')
          services_url = "#{api_url}v1/proxy/namespaces/kube-system/services/"
          {
            'Kubernetes UI' => "#{services_url}kube-ui/",
            'Grafana' => "#{services_url}monitoring-grafana/",
            'Kibana' => "#{services_url}kibana-logging/",
            'Logs' => "#{services_url}logs/",
            'Swagger UI' => "#{root_url}swagger-ui/"
          }
        end
      end
    end
  end
end

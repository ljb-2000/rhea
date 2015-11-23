module Rhea
  module Kubernetes
    class Service
      def self.names_paths
        @names_paths ||= begin
          api_url = Rhea.settings[:kube_api][:url]
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
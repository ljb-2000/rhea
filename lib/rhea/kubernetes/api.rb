module Rhea
  module Kubernetes
    class Api
      attr_accessor :client

      def initialize
        self.client = Kubeclient::Client.new(Rhea.configuration.kube_api[:url] , 'v1', Rhea.configuration.kube_api[:options])
      end

      def method_missing(method, *args)
        self.client.public_send(method, *args)
      end
    end
  end
end

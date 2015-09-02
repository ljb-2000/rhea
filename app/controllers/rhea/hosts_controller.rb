module Rhea
  class HostsController < Rhea::BaseController
    def index
      @hostnames_hosts = Rhea::Kubernetes::Host.hostnames_hosts
    end
  end
end

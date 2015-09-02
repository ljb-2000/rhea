module Rhea
  module Kubernetes
    class Host
      class << self
        def hostnames_hosts
          api = Rhea::Kubernetes::Api.new
          pods = api.get_pods
          hostnames_hosts = {}
          pods.each do |pod|
            queue_identifer = pod.metadata.annotations.rhea_queue_identifier
            next if queue_identifer.nil?
            hostname = pod.spec.host

            started_at = pod.status.startTime
            if started_at
              started_at = Time.parse(started_at)
              hostnames_hosts[hostname] ||= {}
              last_started_at = hostnames_hosts[hostname][:last_started_at]
              if last_started_at.nil? || started_at > last_started_at
                hostnames_hosts[hostname][:last_started_at] = started_at
              end
            end

            phase = pod.status.phase
            containers = pod.spec.containers
            containers.each do |container|
              name = container.name
              hostnames_hosts[hostname] ||= {}
              hostnames_hosts[hostname][:queue_identifers_phases] ||= {}
              hostnames_hosts[hostname][:queue_identifers_phases][queue_identifer] ||= []
              hostnames_hosts[hostname][:queue_identifers_phases][queue_identifer] << phase
            end
          end
          hostnames_hosts
        end
      end
    end
  end
end

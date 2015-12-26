module Rhea
  module Kubernetes
    module Nodes
      class All
        def perform
          api = Rhea::Kubernetes::Api.new
          pods = api.get_pods
          hostnames_nodes = {}
          pods.each do |pod|
            command_expression = pod.metadata.annotations.rhea_command
            next if command_expression.nil?
            hostname = pod.spec.nodeName
            hostnames_nodes[hostname] ||= {}
            hostnames_nodes[hostname][:image] = pod.status.containerStatuses_as_a_hash[0]['image']

            started_at = pod.status.startTime
            if started_at
              started_at = Time.parse(started_at)
              last_started_at = hostnames_nodes[hostname][:last_started_at]
              if last_started_at.nil? || started_at > last_started_at
                hostnames_nodes[hostname][:last_started_at] = started_at
              end
            end

            phase = pod.status.phase
            containers = pod.spec.containers
            containers.each do |container|
              image = container.image
              command = Command.new(
                expression: command_expression,
                image: image
              )
              hostnames_nodes[hostname][:commands_phases] ||= {}
              hostnames_nodes[hostname][:commands_phases][command] ||= []
              hostnames_nodes[hostname][:commands_phases][command] << phase
            end
          end
          hostnames_nodes.map do |hostname, node|
            OpenStruct.new(node.merge(hostname: hostname))
          end
        end
      end
    end
  end
end

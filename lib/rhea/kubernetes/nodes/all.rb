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

            started_at = pod.status.startTime
            if started_at
              started_at = Time.parse(started_at)
              hostnames_nodes[hostname] ||= {}
              last_started_at = hostnames_nodes[hostname][:last_started_at]
              if last_started_at.nil? || started_at > last_started_at
                hostnames_nodes[hostname][:last_started_at] = started_at
              end
            end

            phase = pod.status.phase
            containers = pod.spec.containers
            containers.each do |container|
              name = container.name
              hostnames_nodes[hostname] ||= {}
              hostnames_nodes[hostname][:command_expressions_phases] ||= {}
              hostnames_nodes[hostname][:command_expressions_phases][command_expression] ||= []
              hostnames_nodes[hostname][:command_expressions_phases][command_expression] << phase
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

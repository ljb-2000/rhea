module Rhea
  module Kubernetes
    module Events
      class Recent
        def perform
          api = Rhea::Kubernetes::Api.new
          events = api.get_events
          events.map! do |event|
            OpenStruct.new(
              hostname: event.source.host,
              message: event.message,
              type: event.reason,
              resource_type: event.involvedObject.kind,
              resource_id: event.involvedObject.name,
              created_at: Time.parse(event.lastTimestamp)
            )
          end
          events.sort_by(&:created_at).reverse
        end
      end
    end
  end
end

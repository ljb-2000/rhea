module Rhea
  module Kubernetes
    class Event
      class << self
        def recent
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
          events.sort_by(&:created_at).reverse[0,50]
        end
      end
    end
  end
end

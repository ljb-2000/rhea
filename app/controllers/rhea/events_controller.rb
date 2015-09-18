module Rhea
  class EventsController < Rhea::BaseController
    def index
      @events = Rhea::Kubernetes::Event.recent
    end
  end
end

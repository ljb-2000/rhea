module Rhea
  class EventsController < Rhea::BaseController
    def index
      @events = Rhea::Kubernetes::Events::Recent.new.perform
    end
  end
end

module Rhea
  class EventsController < Rhea::BaseController
    def index
      events = Rhea::Kubernetes::Events::Recent.new.perform
      @events = Kaminari.paginate_array(events).page(params[:page]).per(200)
    end
  end
end

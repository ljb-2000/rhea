module Rhea
  class NodesController < Rhea::BaseController
    def index
      @nodes = Rhea::Kubernetes::Nodes::All.new.perform
    end
  end
end

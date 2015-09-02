module Rhea
  module Resque
    class Worker
      attr_accessor :queue_identifier, :queue_names

      def initialize(queue_identifier:, queue_names:)
        self.queue_identifier = queue_identifier
        self.queue_names = queue_names
      end

      class << self
        def all
          ::Resque.workers.map do |worker|
            queues = worker.queues
            new(queue_names: queues, queue_identifier: queues.join(','))
          end
        end
      end
    end
  end
end

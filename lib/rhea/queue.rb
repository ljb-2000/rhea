module Rhea
  class Queue
    attr_accessor :name, :jobs_count, :workers_count

    def initialize(name:, jobs_count: nil, workers_count: nil)
      self.name = name
      self.jobs_count = jobs_count
    end

    class << self
      def all
        queues = ::Resque.queues.map do |name|
          jobs_count = ::Resque.size(name)
          new(name: name, jobs_count: jobs_count)
        end
        queues.sort_by(&:name)
      end
    end
  end
end

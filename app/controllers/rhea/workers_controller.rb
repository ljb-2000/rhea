module Rhea
  class WorkersController < Rhea::BaseController
    def index
      @queue_names_queues = Rhea::Queue.all.reduce({}) do |hash, queue|
        hash[queue.name] = queue
        hash
      end

      @queues_worker_counts = Hash.new(0)
      @queue_identifiers_worker_counts = Hash.new(0)
      workers = Rhea::Resque::Worker.all
      workers.each do |worker|
        @queue_identifiers_worker_counts[worker.queue_identifier] += 1
        worker.queue_names.each do |queue_name|
          @queues_worker_counts[queue_name] += 1
        end
      end
      
      @queues_worker_counts = Hash[@queues_worker_counts.sort_by(&:first)]
      @queue_identifiers_workers_counts = Rhea::Kubernetes::Worker.queue_identifiers_workers_counts
    end

    def update_all
      # TODO: Don't scale unless necessary
      queue_identifiers_distributed_worker_counts = params[:queue_identifiers_distributed_worker_counts]
      queue_identifiers_distributed_worker_counts.each do |queue_identifier, distributed_worker_count|
        next if distributed_worker_count.blank?
        distributed_worker_count = distributed_worker_count.to_i
        begin
          Rhea::Kubernetes::Worker.scale(queue_identifier, distributed_worker_count)
          # Sleep briefly to prevent user needing to refresh page to see updated count
          sleep 0.1
        rescue Rhea::Kubernetes::ServerError => e
          flash[:alert] = e.message
          redirect_to :back and return
        end
      end
      redirect_to params[:redirect_to], notice: 'Saved!'
    end

    def start
      queue_identifier = params[:queue_identifier].presence
      workers_count = params[:workers_count].presence

      redirect_to :back, flash: { error: 'Blank queue_identifier' } and return if queue_identifier.blank?
      redirect_to :back, flash: { error: 'Blank workers_count' } and return if workers_count.blank?

      Rhea::Kubernetes::Worker.scale(queue_identifier, workers_count.to_i)
      # Sleep briefly to prevent user needing to refresh page to see updated count
      sleep 0.1
      redirect_to params[:redirect_to], notice: 'Started!'
    end
  end
end

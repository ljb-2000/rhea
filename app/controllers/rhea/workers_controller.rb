module Rhea
  class WorkersController < Rhea::BaseController
    def index
      @commands_workers_counts = Rhea::Kubernetes::Worker.commands_workers_counts
    end

    def delete
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Worker.destroy(command)
      flash[:notice] = "Command '#{command}' deleted"
      redirect_to :back
    end

    def update_all
      # TODO: Don't scale unless necessary
      commands_worker_counts = params[:commands_worker_counts]
      commands_worker_counts.each do |command, worker_count|
        next if worker_count.blank?
        worker_count = worker_count.to_i
        begin
          Rhea::Kubernetes::Worker.scale(command, worker_count)
          # Sleep briefly to prevent user needing to refresh page to see updated count
          sleep 0.2
        rescue Rhea::Kubernetes::ServerError => e
          flash[:alert] = e.message
          redirect_to :back and return
        end
      end
      redirect_to params[:redirect_to], notice: 'Saved!'
    end

    def start
      command_type_key = params[:command_type_key].presence
      command_type_input = params[:command_type_input].presence
      workers_count = params[:workers_count].presence

      redirect_to :back, flash: { error: 'Blank command_type_key' } and return if command_type_key.blank?
      redirect_to :back, flash: { error: 'Blank command_type_input' } and return if command_type_input.blank?
      redirect_to :back, flash: { error: 'Blank workers_count' } and return if workers_count.blank?

      command_type = Rhea::CommandType.find(command_type_key)
      command = command_type.input_to_command(command_type_input)

      Rhea::Kubernetes::Worker.scale(command, workers_count.to_i)
      # Sleep briefly to prevent user needing to refresh page to see updated counts
      sleep 0.1
      redirect_to params[:redirect_to], notice: 'Started!'
    end
  end
end

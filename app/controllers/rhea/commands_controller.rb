module Rhea
  class CommandsController < Rhea::BaseController
    def index
      @commands = Rhea::Kubernetes::Commands::All.new.perform
      @images = @commands.map(&:image).uniq.sort
      @default_image = Rhea.settings[:image].split('/').last
      params[:image] ||= @default_image
      if params[:image].present?
        @commands = @commands.select { |command| command.image == params[:image] }
      end
    end

    def delete
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Commands::Delete.new(command).perform
      flash[:notice] = "Command '#{command}' deleted"
      redirect_to :back
    end

    def update_all
      # TODO: Don't scale unless necessary
      commands_process_counts = params[:commands_process_counts]
      commands_process_counts.each do |command, process_count|
        next if process_count.blank?
        process_count = process_count.to_i
        begin
          Rhea::Kubernetes::Commands::Scale.new(command, process_count).perform
          # Sleep briefly to prevent user needing to refresh page to see updated count
          sleep 0.2
        rescue Rhea::Kubernetes::ServerError => e
          flash[:alert] = e.message
          redirect_to :back and return
        end
      end
      redirect_to params[:redirect_to], notice: 'Saved!'
    end

    def create
      command_type_key = params[:command_type_key].presence
      command_type_input = params[:command_type_input].presence
      process_count = params[:process_count].presence

      redirect_to :back, flash: { error: 'Blank command_type_key' } and return if command_type_key.blank?
      redirect_to :back, flash: { error: 'Blank command_type_input' } and return if command_type_input.blank?
      redirect_to :back, flash: { error: 'Blank process_count' } and return if process_count.blank?

      command_type = Rhea::CommandType.find(command_type_key)
      command = command_type.input_to_command(command_type_input)

      Rhea::Kubernetes::Commands::Scale.new(command, process_count.to_i).perform
      # Sleep briefly to prevent user needing to refresh page to see updated counts
      sleep 0.1
      redirect_to params[:redirect_to], notice: 'Command created!'
    end
  end
end

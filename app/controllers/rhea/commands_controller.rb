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
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: 'Command created!'
    end

    def batch_update
      case params[:batch_action]
      when 'redeploy'
        batch_redeploy
      when 'reschedule'
        batch_reschedule
      when 'scale'
        batch_scale
      when 'stop'
        batch_stop
      else
        redirect_to params[:redirect_to], notice: 'Invalid action!'
      end
    end

    def delete
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Commands::Delete.new(command).perform
      flash[:notice] = "Command '#{command}' deleted!"
      redirect_to :back
    end

    def redeploy
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Commands::Redeploy.new(command).perform
      flash[:notice] = "Command '#{command}' redeployed!"
      redirect_to :back
    end

    def reschedule
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Commands::Reschedule.new(command).perform
      flash[:notice] = "Command '#{command}' rescheduled!"
      redirect_to :back
    end

    def stop
      command = params[:command]
      command = CGI.unescape(command)
      Rhea::Kubernetes::Commands::Scale.new(command, 0).perform
      flash[:notice] = "Command '#{command}' stopped!"
      redirect_to :back
    end

    private

    def batch_redeploy
      commands = params[:batch_commands]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if commands.blank?
      threads = commands.map do |command|
        command = CGI.unescape(command)
        Thread.new do
          Rhea::Kubernetes::Commands::Redeploy.new(command).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Redeployed #{commands.length} #{'command'.pluralize(commands.length)}!"
    end

    def batch_reschedule
      commands = params[:batch_commands]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if commands.blank?
      threads = commands.map do |command|
        command = CGI.unescape(command)
        Thread.new do
          Rhea::Kubernetes::Commands::Reschedule.new(command).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Rescheduleed #{commands.length} #{'command'.pluralize(commands.length)}!"
    end

    def batch_scale
      commands_process_counts = params[:commands_process_counts]
      scaled_commands_count = 0
      commands_process_counts.each do |command, process_count|
        next if process_count.blank?
        process_count = process_count.to_i
        command = CGI.unescape(command)
        Rhea::Kubernetes::Commands::Scale.new(command, process_count).perform
        scaled_commands_count += 1
      end
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Scaled #{scaled_commands_count} #{'command'.pluralize(scaled_commands_count)}!"
    end

    def batch_stop
      commands = params[:batch_commands]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if commands.blank?
      threads = commands.map do |command|
        command = CGI.unescape(command)
        Thread.new do
          Rhea::Kubernetes::Commands::Scale.new(command, 0).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Stopped #{commands.length} #{'command'.pluralize(commands.length)}!"
    end

    # Sleep briefly to prevent user needing to refresh the page to see updated counts
    def wait_for_updates_to_persist
      sleep 0.2
    end
  end
end

module Rhea
  class CommandsController < Rhea::BaseController
    def index
      @commands = Rhea::Kubernetes::Commands::All.new.perform
      @default_image = Rhea.configuration.image
      @images = (@commands.map(&:image) + [@default_image]).uniq.sort
      params[:image] ||= @default_image
      if params[:image].present?
        @commands = @commands.select { |command| command.image == params[:image] }
      end
    end

    def create
      command_type_key = params[:command_type_key].presence
      command_type_input = params[:command_type_input].presence
      process_count = params[:process_count].presence || 1

      redirect_to :back, flash: { error: 'Blank command_type_key' } and return if command_type_key.blank?
      redirect_to :back, flash: { error: 'Blank command_type_input' } and return if command_type_input.blank?
      redirect_to :back, flash: { error: 'Blank process_count' } and return if process_count.blank?

      command_type = Rhea::CommandType.find(command_type_key)
      command_expression = command_type.input_to_command_expression(command_type_input)

      Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count.to_i).perform
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
      command_expression = params[:command_expression]
      command_expression = CGI.unescape(command_expression)
      Rhea::Kubernetes::Commands::Delete.new(command_expression).perform
      flash[:notice] = "Command '#{command_expression}' deleted!"
      redirect_to :back
    end

    def redeploy
      command_expression = params[:command_expression]
      command_expression = CGI.unescape(command_expression)
      Rhea::Kubernetes::Commands::Redeploy.new(command_expression).perform
      flash[:notice] = "Command '#{command_expression}' redeployed!"
      redirect_to :back
    end

    def reschedule
      command_expression = params[:command_expression]
      command_expression = CGI.unescape(command_expression)
      Rhea::Kubernetes::Commands::Reschedule.new(command_expression).perform
      flash[:notice] = "Command '#{command_expression}' rescheduled!"
      redirect_to :back
    end

    def stop
      command_expression = params[:command_expression]
      command_expression = CGI.unescape(command_expression)
      Rhea::Kubernetes::Commands::Scale.new(command_expression, 0).perform
      flash[:notice] = "Command '#{command_expression}' stopped!"
      redirect_to :back
    end

    private

    def batch_redeploy
      command_expressions = params[:batch_command_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if command_expressions.blank?
      threads = command_expressions.map do |command_expression|
        command_expression = CGI.unescape(command_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Redeploy.new(command_expression).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Redeployed #{command_expressions.length} #{'command'.pluralize(command_expressions.length)}!"
    end

    def batch_reschedule
      command_expressions = params[:batch_command_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if command_expressions.blank?
      threads = command_expressions.map do |command_expression|
        command_expression = CGI.unescape(command_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Reschedule.new(command_expression).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Rescheduled #{command_expressions.length} #{'command'.pluralize(command_expressions.length)}!"
    end

    def batch_scale
      command_expressions_process_counts = params[:command_expressions_process_counts]
      scaled_commands_count = 0
      command_expressions_process_counts.each do |command_expression, process_count|
        next if process_count.blank?
        process_count = process_count.to_i
        command_expression = CGI.unescape(command_expression)
        Rhea::Kubernetes::Commands::Scale.new(command_expression, process_count).perform
        scaled_commands_count += 1
      end
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Scaled #{scaled_commands_count} #{'command'.pluralize(scaled_commands_count)}!"
    end

    def batch_stop
      command_expressions = params[:batch_command_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if command_expressions.blank?
      threads = command_expressions.map do |command_expression|
        command_expression = CGI.unescape(command_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Scale.new(command_expression, 0).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Stopped #{command_expressions.length} #{'command'.pluralize(command_expressions.length)}!"
    end

    # Sleep briefly to prevent user needing to refresh the page to see updated counts
    def wait_for_updates_to_persist
      sleep 0.2
    end
  end
end

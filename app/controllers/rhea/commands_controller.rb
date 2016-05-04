module Rhea
  class CommandsController < Rhea::BaseController
    def index
      @commands = Rhea::Kubernetes::Commands::All.new.perform
      @default_image = Rhea.configuration.default_image
      @images = (@commands.map(&:image) + [@default_image]).uniq.sort
      params[:image] ||= @default_image
      if params[:image].present?
        @commands = @commands.select { |command| command.image == params[:image] }
      end
    end

    def create
      command_type_key = params[:command_type_key].presence
      command_type_input = params[:command_type_input]
      process_count = params[:process_count].presence.try(:to_i) || 1
      image = params[:image].presence

      redirect_to :back, flash: { error: 'Blank command_type_key' } and return if command_type_key.blank?
      redirect_to :back, flash: { error: 'Blank process_count' } and return if process_count.blank?
      redirect_to :back, flash: { error: 'Blank image' } and return if image.blank?

      command_type = Rhea::CommandType.find(command_type_key)
      command_expression = command_type.input_to_command_expression(command_type_input)

      Rhea::Kubernetes::Commands::Scale.new(expression: command_expression, image: image, process_count: process_count).perform
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
      command_attributes = image_expression_to_command_attributes(params[:image_expression])
      Rhea::Kubernetes::Commands::Delete.new(command_attributes).perform
      flash[:notice] = "Command '#{command_attributes[:expression]}' deleted!"
      redirect_to :back
    end

    def export
      data = Rhea::Kubernetes::Commands::Export.new.perform
      respond_to do |format|
        format.json { send_data data.to_json, type: :json, disposition: 'attachment' }
      end
    end

    def import
      data = ActiveSupport::JSON.decode(params[:data].read)
      commands = data['commands']
      if commands.nil?
        flash[:alert] = 'Invalid file'
        redirect_to :back
        return
      end

      Rhea::Kubernetes::Commands::Import.new(data).perform
      flash[:notice] = "Imported #{commands.length} commands!"
      redirect_to :back
    end

    def redeploy
      command_attributes = image_expression_to_command_attributes(params[:image_expression])
      Rhea::Kubernetes::Commands::Redeploy.new(command_attributes).perform
      flash[:notice] = "Command '#{command_attributes[:expression]}' redeployed!"
      redirect_to :back
    end

    def reschedule
      command_attributes = image_expression_to_command_attributes(params[:image_expression])
      Rhea::Kubernetes::Commands::Reschedule.new(command_attributes).perform
      flash[:notice] = "Command '#{command_attributes[:expression]}' rescheduled!"
      redirect_to :back
    end

    def stop
      command_attributes = image_expression_to_command_attributes(params[:image_expression])
      Rhea::Kubernetes::Commands::Scale.new(command_attributes.merge(process_count: 0)).perform
      flash[:notice] = "Command '#{command_attributes[:expression]}' stopped!"
      redirect_to :back
    end

    private

    def batch_redeploy
      image_expressions = params[:batch_image_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if image_expressions.blank?
      threads = image_expressions.map do |image_expression|
        command_attributes = image_expression_to_command_attributes(image_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Redeploy.new(command_attributes).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Redeployed #{image_expressions.length} #{'command'.pluralize(image_expressions.length)}!"
    end

    def batch_reschedule
      image_expressions = params[:batch_image_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if image_expressions.blank?
      threads = image_expressions.map do |image_expression|
        command_attributes = image_expression_to_command_attributes(image_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Reschedule.new(command_attributes).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Rescheduled #{image_expressions.length} #{'command'.pluralize(image_expressions.length)}!"
    end

    def batch_scale
      image_expressions_process_counts = params[:image_expressions_process_counts]
      scaled_commands_count = 0
      image_expressions_process_counts.each do |image_expression, process_count|
        next if process_count.blank?
        process_count = process_count.to_i
        command_attributes = image_expression_to_command_attributes(image_expression)
        Rhea::Kubernetes::Commands::Scale.new(command_attributes.merge(process_count: process_count)).perform
        scaled_commands_count += 1
      end
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Scaled #{scaled_commands_count} #{'command'.pluralize(scaled_commands_count)}!"
    end

    def batch_stop
      image_expressions = params[:batch_image_expressions]
      redirect_to params[:redirect_to], notice: 'No commands were selected!' and return if image_expressions.blank?
      threads = image_expressions.map do |image_expression|
        command_attributes = image_expression_to_command_attributes(image_expression)
        Thread.new do
          Rhea::Kubernetes::Commands::Scale.new(command_attributes.merge(process_count: 0)).perform
        end
      end
      threads.map(&:join)
      wait_for_updates_to_persist
      redirect_to params[:redirect_to], notice: "Stopped #{image_expressions.length} #{'command'.pluralize(image_expressions.length)}!"
    end

    # Sleep briefly to prevent user needing to refresh the page to see updated counts
    def wait_for_updates_to_persist
      sleep 0.2
    end

    # TODO: Use proper form submissions instead of string concatenation
    def image_expression_to_command_attributes(image_expression)
      image_expression = CGI.unescape(image_expression)
      image, expression = image_expression.split(Rhea::Command::IMAGE_EXPRESSION_SEPARATOR, 2)
      {
        image: image,
        expression: expression
      }
    end
  end
end

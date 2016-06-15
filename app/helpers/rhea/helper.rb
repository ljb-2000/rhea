module Rhea
  module Helper
    def app_name
      'Rhea'
    end

    def root_path
      Rhea.root_path
    end

    def humanize_image(image)
      image.split('/').last
    end

    ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

    def bootstrap_flash(options = {})
      flash_messages = []
      flash.each do |type, message|
        # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
        next if message.blank?

        type = type.to_sym
        type = :success if type == :notice
        type = :danger  if type == :alert
        type = :danger  if type == :error
        next unless ALERT_TYPES.include?(type)

        tag_class = options.extract!(:class)[:class]
        tag_options = {
          class: "alert fade in alert-#{type} #{tag_class}"
        }.merge(options)

        Array(message).each do |msg|
          text = content_tag(:div, msg.html_safe, tag_options)
          flash_messages << text if msg
        end
      end
      flash_messages.join("\n").html_safe
    end

    IMAGE_ID_REGEX = /^docker:\/\/sha256:([a-z0-9]+)/.freeze
    def humanize_image_id(image_id)
      IMAGE_ID_REGEX.match(image_id).try(:[], 1).try(:first, 12)
    end
  end
end

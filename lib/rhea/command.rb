module Rhea
  class Command
    attr_accessor :expression, :image, :process_count, :created_at

    KEY_PREFIX = 'rhea-'
    IMAGE_EXPRESSION_SEPARATOR = '____'

    def initialize(expression:, image: nil, process_count: nil, created_at: nil)
      self.expression = expression
      self.image = image || Rhea.configuration.default_image
      self.process_count = process_count
      self.created_at = created_at
    end

    def attributes
      {
        expression: expression,
        image: image,
        process_count: process_count,
        created_at: created_at
      }
    end

    def key
      command_hash = Digest::MD5.hexdigest("#{image}#{expression}")[0..3]
      command_for_host = expression.downcase.gsub(/[^-a-z0-9]+/i, '-').squeeze('-')
      key = "#{KEY_PREFIX}#{command_hash}-#{command_for_host}"
      max_host_name_length = 62
      key = key[0,max_host_name_length]
      # The key can't end with a '-'
      key.gsub!(/\-+$/, '')
      key
    end

    def image_ids
      pods = Rhea::Kubernetes::Pods::Get.new(attributes).perform
      return [] if pods.empty?
      ids = pods.map do |pod|
        pod.status.containerStatuses.map do |container_status|
          container_status.imageID
        end
      end
      ids.flatten!
      ids.uniq!
      ids
    end
  end
end

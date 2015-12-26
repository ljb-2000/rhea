module Rhea
  class Command
    attr_accessor :expression, :image, :process_count, :created_at

    def initialize(expression:, image:, process_count: nil, created_at: nil)
      self.expression = expression
      self.image = image
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
  end
end

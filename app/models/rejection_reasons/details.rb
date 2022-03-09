class RejectionReasons
  class Details
    include ActiveModel::Model
    WORD_COUNT = 100

    attr_accessor :id, :label, :text
    validate :text_present, :word_count

    def inflate(model)
      @text = model.send(id)
      self
    end

    def text_present
      errors.add(id, 'Please give details') if text.blank?
    end

    def word_count
      if text.present? && text.scan(/\S+/).size > WORD_COUNT
        errors.add(id, 'Details are too long')
      end
    end
  end
end

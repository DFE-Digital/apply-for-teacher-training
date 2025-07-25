class RejectionReasons
  class Details
    include ActiveModel::Model

    MAX_WORDS = 200

    attr_accessor :id, :label, :text, :optional, :visually_hidden
    validate :text_present, :word_count, unless: -> { optional }

    def inflate(model)
      @text = model.send(id)
      self
    end

    def as_json
      { id:, text: }
    end

    def text_present
      errors.add(id, RejectionReasons.translated_error(id, :blank)) if text.blank?
    end

    def word_count
      if text.present? && text.scan(/\S+/).size > MAX_WORDS
        errors.add(id, RejectionReasons.translated_error(id, :size))
      end
    end
  end
end

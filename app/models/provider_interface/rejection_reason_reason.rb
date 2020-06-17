module ProviderInterface
  class RejectionReasonReason
    include ActiveModel::Model

    attr_accessor :label
    attr_accessor :value
    attr_accessor :explanation
    attr_accessor :advice
    attr_writer :textareas

    validate :textareas_all_valid?, if: -> { value.present? }

    alias_method :id, :label

    def selected?
      value.present?
    end

    def textareas
      @textareas ||= []
    end

    def textareas_all_valid?
      textareas.each_with_index do |t, i|
        next unless t.invalid?

        t.errors.each do |attr, message|
          errors.add("textareas[#{i}].#{attr}", message)
        end
      end
    end

    def textareas_attributes=(attributes)
      @textareas ||= []
      attributes.each do |_id, r|
        @textareas.push(RejectionReasonTextarea.new(r))
      end
    end
  end
end

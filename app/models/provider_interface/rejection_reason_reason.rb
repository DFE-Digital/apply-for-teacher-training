module ProviderInterface
  class RejectionReasonReason
    include ActiveModel::Model

    attr_accessor :label
    attr_accessor :value
    attr_accessor :explanation
    attr_accessor :advice
    attr_accessor :textareas
    validates :explanation, presence: true, if: -> { reason_with_textarea_selected? }
    validates :advice, presence: true, if: -> { reason_with_textarea_selected? }

    alias_method :id, :label

  private

    def reason_with_textarea_selected?
      value.present? && textareas.present?
    end
  end
end

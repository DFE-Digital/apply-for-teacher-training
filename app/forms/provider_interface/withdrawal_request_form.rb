module ProviderInterface
  class WithdrawalRequestForm
    include ActiveModel::Model

    attr_accessor :reason, :comment, :id

    validates :reason, presence: true
    validates :comment, presence: true, if: :other?
    validates :comment, word_count: { maximum: 200 }

    def initialize(attributes = nil, application_choice:)
      @application_choice = application_choice
      super(attributes)
    end

    def persist!
      if valid?
        withdrawal_request = @application_choice.withdrawal_requests.new(attributes)
        withdrawal_request.save!
      end
    end

    def reason_options
      option = Struct.new(:id, :name, :other_reason)

      WithdrawalRequest.selectable_reasons.keys.map do |reason|
        option.new(
          id: reason,
          name: translate("#{reason}.label"),
          other_reason: reason == 'other' ? translate("#{reason}.comment.label") : nil,
        )
      end
    end

    def other?
      reason == 'other'
    end

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("provider_interface.withdrawal_requests.reasons.#{string}")
    end
  end
end

module CandidateInterface
  class WithdrawalReasonsForm
    include ActiveModel::Model

    attr_accessor :reason, :comment, :reason_id
    validates :reason, presence: true
    validates :comment, presence: true, if: :other_reason?
    validates :comment, length: { maximum: 256 }

    def other_reason?
      reason == 'other'
    end

    def saveable?
      # this will be different for secondary reasons.
      valid? && other_reason?
    end

    def reason_options
      reason = Struct.new(:id, :name, :text_area_label)
      WithdrawalReason.find_reason_options(reason_id || '').keys.map do |r|
        full_reason = [reason_id, r].compact.join('.')
        reason.new(
          id: r,
          name: translate("#{full_reason}.label"),
          text_area_label: r == 'other' ? translate("#{full_reason}.comment.label") : nil,
        )
      end
    end

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
    end
  end
end

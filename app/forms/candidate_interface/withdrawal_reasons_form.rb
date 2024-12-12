module CandidateInterface
  class WithdrawalReasonsForm
    include ActiveModel::Model

    attr_accessor :reason, :comment, :reason_id
    validates :reason, presence: true
    validates :comment, presence: true, if: :other_reason?
    validates :comment, length: { maximum: 256 }

    def initialize(attributes = {}, application_choice = nil)
      @application_choice = application_choice
      super(attributes)
    end

    def saveable?
      # this will be different for secondary reasons.
      valid? && other_reason?
    end

    def save!
      raise unless saveable?

      WithdrawApplication.new(application_choice: @application_choice).save!
      @application_choice.withdrawal_reasons.create!(reason:, comment:)
    end

    def confirm_params
      { reason:, comment: }
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

    def primary_reason_text
      [translate("#{reason}.label"), comment].join(': ')
    end

    def secondary_reason_title
      translate("#{reason_id || reason}.secondary_reasons_title")
    end

  private

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
    end

    def other_reason?
      reason == 'other'
    end
  end
end

module CandidateInterface
  class WithdrawalReasonsForm
    include ActiveModel::Model

    attr_accessor :primary_reason_id, # The id is in the url params, once we have moved to the second step
                  :primary_reason, # The selected primary reason in the first step
                  :primary_other_comment,
                  :secondary_reasons
    validates :primary_reason, presence: true
    validates :primary_other_comment, presence: true, if: :primary_other_reason?
    validates :primary_other_comment, word_count: { maximum: 200 }

    def initialize(attributes = {}, application_choice: nil)
      @application_choice = application_choice
      super(attributes)
    end

    def saveable?
      # this will be different for secondary reasons.
      valid? && primary_other_reason?
    end

    def save!
      raise unless saveable?

      WithdrawApplication.new(application_choice: @application_choice).save!
      @application_choice.withdrawal_reasons.create!(
        reason: primary_reason,
        comment: primary_other_comment,
      )
    end

    def confirm_params
      { primary_reason:, primary_other_comment: }
    end

    def reason_options(reason_id = primary_reason_id)
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
      [translate("#{primary_reason}.label"), primary_other_comment].join(': ')
    end

    def secondary_reason_title
      translate("#{primary_reason_id}.secondary_reasons_title")
    end

  private

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
    end

    def primary_other_reason?
      primary_reason == 'other'
    end
  end
end

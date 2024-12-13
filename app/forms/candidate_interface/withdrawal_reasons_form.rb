module CandidateInterface
  class WithdrawalReasonsForm
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    before_validation :sanitise_reasons, if: :secondary_reason_step?

    attr_accessor :form_step, # Either primary or secondary
                  :primary_reason_id, # The id is in the url params, once we have moved to the second step
                  :primary_reason, # The selected reason in the first step
                  :primary_other_comment,
                  :secondary_reasons # The multiselect in the second step

    validates :primary_reason, presence: true
    validates :primary_other_comment, presence: true, if: :primary_other_reason?
    validates :primary_other_comment, word_count: { maximum: 200 }
    validates :secondary_reasons,
              presence: true,
              if: :secondary_reason_step?

    after_validation :adjust_error_messages, if: :secondary_reason_step?

    def initialize(attributes = {}, application_choice: nil)
      @application_choice = application_choice
      super(attributes)
    end

    def secondary_reason_step?
      form_step == 'secondary_reasons'
    end

    def primary_reason_step?
      form_step == 'primary_reason'
    end

    def saveable?
      if primary_reason_step?
        valid? && primary_other_reason?
      else
        valid?
      end
    end

    def save!
      WithdrawApplication.new(application_choice: @application_choice).save!
      if secondary_reasons.empty?
        @application_choice.withdrawal_reasons.create!(
          reason: primary_reason_id,
          comment: primary_other_comment,
        )
      else
        secondary_reasons.compact.each do |reason|
          @application_choice.withdrawal_reasons.create!(
            reason: [primary_reason_id, reason].join('.'),
          )
        end
      end
    end

    def confirm_params
      {
        primary_other_comment:,
        secondary_reasons:,
      }
    end

    def primary_reason_options
      reason_options('')
    end

    def reason_options(reason_id)
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
      [translate("#{primary_reason_id}.label"), primary_other_comment].compact.join(': ')
    end

    def reason_details
      secondary_reasons.compact_blank.map do |reason|
        translate("#{primary_reason_id}.#{reason}.label")
      end
    end

    def secondary_reason_title(reason_id)
      translate("#{reason_id}.secondary_reasons_title")
    end

  private

    def adjust_error_messages
      return unless errors.added?(:secondary_reasons, :blank)

      errors.delete(:secondary_reasons)
      errors.add(
        :secondary_reasons,
        I18n.t("activemodel.errors.models.candidate_interface/withdrawal_reasons_form.attributes.secondary_reasons.blank.#{primary_reason.gsub('-', '_')}"),
      )
    end

    def sanitise_reasons
      self.primary_reason = primary_reason_id if primary_reason.blank?
      self.secondary_reasons = secondary_reasons.compact_blank
    end

    def translate(string)
      string.gsub!('-', '_')
      I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
    end

    def primary_other_reason?
      primary_reason == 'other'
    end
  end
end

module CandidateInterface
  module WithdrawalReasons
    class LevelTwoReasonsForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks
      include Rails.application.routes.url_helpers

      attr_accessor :level_one_reason,
                    :level_two_reasons,
                    :personal_circumstances_reasons,
                    :personal_circumstances_reasons_comment,
                    :comment

      validate :level_two_reasons_presence
      validates :personal_circumstances_reasons,
                presence: true,
                if: :personal_circumstances_reasons_required?
      validates :personal_circumstances_reasons_comment,
                presence: true,
                if: :personal_circumstances_reasons_comment_required?
      validates :personal_circumstances_reasons_comment, word_count: { maximum: 200 }
      validates :comment, presence: true, if: :other?
      validates :comment, word_count: { maximum: 200 }

      before_validation :sanitize_reasons

      PERSONAL_CIRCUMSTANCES_KEY = WithdrawalReason::PERSONAL_CIRCUMSTANCES_KEY

      def self.build_from_application_choice(level_one_reason, application_choice)
        form_builder = LevelTwoReasonsBuilder.new(level_one_reason, application_choice)
        new(
          { **form_builder.form_attributes },
          application_choice:,
          withdrawal_reasons: form_builder.withdrawal_reasons,
        )
      end

      def initialize(attributes = {}, application_choice: nil, withdrawal_reasons: nil)
        @application_choice = application_choice
        @withdrawal_reasons = withdrawal_reasons
        super(attributes)
      end

      def persist!
        # Reasons can be orphaned if the user abandons the withdrawal form before confirming or cancelling.
        # So we want to destroy any existing drafts; and only save for review what is in the current form.
        ActiveRecord::Base.transaction do
          @application_choice.draft_withdrawal_reasons.destroy_all

          # Then create from valid form attributes
          [level_two_reasons, personal_circumstances_reasons].flatten.compact.each do |reason|
            next if reason == PERSONAL_CIRCUMSTANCES_KEY

            other_comment = if reason == 'other'
                              comment
                            elsif reason == "#{PERSONAL_CIRCUMSTANCES_KEY}.other"
                              personal_circumstances_reasons_comment
                            end

            @application_choice.draft_withdrawal_reasons.create!(
              reason: "#{level_one_reason}.#{reason}",
              comment: other_comment,
            )
          end
        end
      end

      def reason_options
        option = Struct.new(:id, :name, :other_reason, :personal_circumstances_reasons)
        WithdrawalReason.get_reason_options(level_one_reason).map do |reason_id, nested_reasons|
          personal_circumstances_reasons = nested_reasons.map do |supporting_reason_id, _options|
            option.new(
              id: "#{reason_id}.#{supporting_reason_id}",
              name: translate("#{reason_id}.#{supporting_reason_id}.label"),
              other_reason: supporting_reason_id == 'other' ? translate("#{reason_id}.#{supporting_reason_id}.comment.label") : nil,
            )
          end

          option.new(
            id: reason_id,
            name: translate("#{reason_id}.label"),
            other_reason: reason_id == 'other' ? translate("#{reason_id}.comment.label") : nil,
            personal_circumstances_reasons: reason_id == 'other' ? nil : personal_circumstances_reasons,
          )
        end
      end

      def form_title
        translate('level_two_reasons_title')
      end

      def return_to_level_one_reasons_path
        if @withdrawal_reasons.present?
          candidate_interface_withdrawal_reasons_level_one_reason_edit_path(@application_choice, withdrawal_reason_id: @withdrawal_reasons.first.id)
        else
          candidate_interface_withdrawal_reasons_level_one_reason_new_path(@application_choice, params: { level_one_reason: })
        end
      end

    private

      def other?
        level_two_reasons.present? && level_two_reasons.include?('other')
      end

      def personal_circumstances_reasons_comment_required?
        personal_circumstances_reasons.present? && personal_circumstances_reasons.include?("#{PERSONAL_CIRCUMSTANCES_KEY}.other")
      end

      def personal_circumstances_reasons_required?
        level_two_reasons.present? && level_two_reasons.include?(PERSONAL_CIRCUMSTANCES_KEY)
      end

      def level_two_reasons_presence
        return if level_two_reasons.present?

        error_type = "blank_#{level_one_reason}".gsub('-', '_').to_sym
        errors.add(:level_two_reasons, error_type)
      end

      def sanitize_reasons
        level_two_reasons.reject!(&:blank?)
        personal_circumstances_reasons.reject!(&:blank?) if personal_circumstances_reasons.present?
      end

      def translate(string)
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{level_one_reason}.#{string}".gsub!('-', '_'))
      end
    end
  end
end

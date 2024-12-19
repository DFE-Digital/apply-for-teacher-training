module CandidateInterface
  module WithdrawalReasons
    class SecondaryReasonsForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      PERSONAL_CIRCUMSTANCES_KEY = 'personal-circumstances-have-changed'.freeze

      attr_accessor :primary_reason,
                    :secondary_reasons,
                    :personal_circumstances_reasons,
                    :personal_circumstances_reasons_comment,
                    :comment

      validate :secondary_reasons_presence
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

      def self.build_from_application_choice(primary_reason, application_choice)
        secondary_reasons = []
        personal_circumstances_reasons = []
        personal_circumstances_reasons_comment = nil
        comment = nil

        withdrawal_reasons = application_choice.draft_withdrawal_reasons.reject do |withdrawal_reason|
          withdrawal_reason.reason.exclude?(primary_reason)
        end

        withdrawal_reasons.each do |withdrawal_reason|
          if withdrawal_reason.reason.include?("#{PERSONAL_CIRCUMSTANCES_KEY}.")
            personal_circumstances_reasons << (withdrawal_reason.reason.split('.') - [primary_reason]).join('.')
            personal_circumstances_reasons_comment = withdrawal_reason.comment if withdrawal_reason.comment.present?
          else
            secondary_reasons << (withdrawal_reason.reason.split('.') - [primary_reason]).join('.')
            comment = withdrawal_reason.comment if withdrawal_reason.comment.present?
          end
        end

        secondary_reasons << PERSONAL_CIRCUMSTANCES_KEY if personal_circumstances_reasons.present?
        new({ primary_reason:, secondary_reasons:, personal_circumstances_reasons:, comment:, personal_circumstances_reasons_comment: }, application_choice:, withdrawal_reasons:)
      end

      def initialize(attributes = {}, application_choice: nil, withdrawal_reasons: nil)
        @application_choice = application_choice
        @withdrawal_reasons = withdrawal_reasons
        super(attributes)
      end

      def create!
        # Destroy any existing drafts; we just want to create what is in the form params
        # Reasons can be orphaned if the user abandons the withdrawal form before confirming or cancelling.
        @application_choice.draft_withdrawal_reasons.destroy_all

        # Then create from valid form attributes
        [secondary_reasons, personal_circumstances_reasons].flatten.compact.each do |reason|
          next if reason == PERSONAL_CIRCUMSTANCES_KEY

          other_comment = if reason == 'other'
                            comment
                          elsif reason == 'personal-circumstances-have-changed.other'
                            personal_circumstances_reasons_comment
                          end

          @application_choice.draft_withdrawal_reasons.create!(
            reason: "#{primary_reason}.#{reason}",
            comment: other_comment,
          )
        end
      end

      def reason_options
        option = Struct.new(:id, :name, :other_reason, :personal_circumstances_reasons)
        WithdrawalReason.find_reason_options(primary_reason).map do |reason_id, nested_reasons|
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
        translate('secondary_reasons_title')
      end

      def return_to_primary_reasons_path
        if @withdrawal_reasons.present?
          Rails.application.routes.url_helpers.candidate_interface_withdrawal_reasons_primary_reason_edit_path(@application_choice, withdrawal_reason_id: @withdrawal_reasons.first.id)
        else
          Rails.application.routes.url_helpers.candidate_interface_withdrawal_reasons_primary_reason_start_path(@application_choice)
        end
      end

    private

      def other?
        secondary_reasons.present? && secondary_reasons.include?('other')
      end

      def personal_circumstances_reasons_comment_required?
        personal_circumstances_reasons.present? && personal_circumstances_reasons.include?('personal-circumstances-have-changed.other')
      end

      def personal_circumstances_reasons_required?
        secondary_reasons.present? && secondary_reasons.include?(PERSONAL_CIRCUMSTANCES_KEY)
      end

      def secondary_reasons_presence
        return if secondary_reasons.present?

        error_type = "blank_#{primary_reason}".gsub('-', '_').to_sym
        errors.add(:secondary_reasons, error_type)
      end

      def sanitize_reasons
        secondary_reasons.reject!(&:blank?)
        personal_circumstances_reasons.reject!(&:blank?) if personal_circumstances_reasons.present?
      end

      def translate(string)
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{primary_reason}.#{string}".gsub!('-', '_'))
      end
    end
  end
end

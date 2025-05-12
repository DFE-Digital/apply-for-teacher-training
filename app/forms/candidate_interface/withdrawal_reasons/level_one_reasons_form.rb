module CandidateInterface
  module WithdrawalReasons
    class LevelOneReasonsForm
      include ActiveModel::Model

      attr_accessor :level_one_reason, :comment, :id

      validates :level_one_reason, presence: true
      validates :comment, presence: true, if: :other?
      validates :comment, word_count: { maximum: 200 }

      def self.build_from_reason(withdraw_reason)
        new(
          {
            level_one_reason: withdraw_reason.reason.split('.').first,
            comment: withdraw_reason.comment,
            id: withdraw_reason.id,
          },
          application_choice: withdraw_reason.application_choice,
        )
      end

      def initialize(attributes = {}, application_choice: nil)
        @application_choice = application_choice
        super(attributes)
      end

      def ready_for_review?
        valid? && other?
      end

      def persist!
        ActiveRecord::Base.transaction do
          @application_choice.withdrawal_reasons.where.not(id:).destroy_all
          if id.present?
            withdrawal_reason = @application_choice.withdrawal_reasons.find(id)
            withdrawal_reason.update!(reason: level_one_reason, comment:)
            withdrawal_reason
          else
            @application_choice.draft_withdrawal_reasons.create!(reason: level_one_reason, comment:)
          end
        end
      end

      def reason_options
        option = Struct.new(:id, :name, :other_reason)
        WithdrawalReason.get_reason_options.keys.map do |reason|
          option.new(
            id: reason,
            name: translate("#{reason}.label"),
            other_reason: reason == 'other' ? translate("#{reason}.comment.label") : nil,
          )
        end
      end

    private

      def other?
        level_one_reason == 'other'
      end

      def translate(string)
        string.gsub!('-', '_')
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
      end
    end
  end
end

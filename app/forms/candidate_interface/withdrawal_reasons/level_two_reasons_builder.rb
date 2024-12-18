module CandidateInterface
  module WithdrawalReasons
    class LevelTwoReasonsBuilder
      PERSONAL_CIRCUMSTANCES_KEY = WithdrawalReason::PERSONAL_CIRCUMSTANCES_KEY

      def initialize(level_one_reason, application_choice)
        @level_one_reason = level_one_reason
        @application_choice = application_choice
      end

      def form_attributes
        {
          level_one_reason: @level_one_reason,
          level_two_reasons:,
          personal_circumstances_reasons:,
          comment:,
          personal_circumstances_reasons_comment:,
        }
      end

      def withdrawal_reasons
        @withdrawal_reasons ||= @application_choice.draft_withdrawal_reasons.by_level_one_reason(@level_one_reason)
      end

    private

      def level_two_reasons
        @level_two_reasons ||= build_level_two_reasons
      end

      def personal_circumstances_reasons
        @personal_circumstances_reasons ||= build_personal_circumstances_reasons
      end

      def personal_circumstances_reasons_comment
        @personal_circumstances_reasons_comment ||= withdrawal_reasons.find do |withdrawal_reason|
          withdrawal_reason.reason.include?("#{PERSONAL_CIRCUMSTANCES_KEY}.other")
        end&.comment
      end

      def comment
        @comment ||= withdrawal_reasons.find do |withdrawal_reason|
          withdrawal_reason.reason.include?("#{@level_one_reason}.other")
        end&.comment
      end

      def build_level_two_reasons
        level_two_reasons = withdrawal_reasons.map do |withdrawal_reason|
          next if withdrawal_reason.reason.include?("#{PERSONAL_CIRCUMSTANCES_KEY}.")

          (withdrawal_reason.reason.split('.') - [@level_one_reason]).join('.')
        end&.compact
        level_two_reasons << PERSONAL_CIRCUMSTANCES_KEY if personal_circumstances_reasons.present?
        level_two_reasons
      end

      def build_personal_circumstances_reasons
        withdrawal_reasons.map do |withdrawal_reason|
          next if withdrawal_reason.reason.exclude?("#{PERSONAL_CIRCUMSTANCES_KEY}.")

          (withdrawal_reason.reason.split('.') - [@level_one_reason]).join('.')
        end&.compact
      end
    end
  end
end

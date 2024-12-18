module CandidateInterface
  module WithdrawalReasons
    class LevelTwoReasonsReviewComponent < ViewComponent::Base
      def initialize(level_one_reason, application_choice:)
        @application_choice = application_choice
        @level_one_reason = level_one_reason
      end

      def level_one_reason_text
        translate("#{@level_one_reason}.label")
      end

      def reason_details
        withdrawal_reasons.pluck(:reason, :comment).map do |reason, comment|
          if reason.include?(personal_circumstances_key)
            reasons_with_further_detail(reason, comment)
          else
            reason_without_further_detail(reason, comment)
          end
        end
      end

      def redirect_id
        withdrawal_reasons.first.id
      end

    private

      def withdrawal_reasons
        @withdrawal_reasons ||= @application_choice.draft_withdrawal_reasons.by_level_one_reason(@level_one_reason)
      end

      def reason_without_further_detail(reason, comment = nil)
        label = translate("#{reason}.label")

        comment.present? ? "#{label}: #{comment}" : label
      end

      def reasons_with_further_detail(reason, comment = nil)
        personal_circumstances_label = translate("#{@level_one_reason}.#{personal_circumstances_key}.label")
        label = translate("#{reason}.label")

        if comment.present?
          "#{personal_circumstances_label} (#{label}): #{comment}"
        else
          "#{personal_circumstances_label}: #{label}"
        end
      end

      def translate(string)
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}".gsub!('-', '_'))
      end

      def personal_circumstances_key
        WithdrawalReason::PERSONAL_CIRCUMSTANCES_KEY
      end
    end
  end
end

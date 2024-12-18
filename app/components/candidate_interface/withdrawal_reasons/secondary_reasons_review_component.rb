module CandidateInterface
  module WithdrawalReasons
    class SecondaryReasonsReviewComponent < ViewComponent::Base
      PERSONAL_CIRCUMSTANCES_KEY = 'personal-circumstances-have-changed'.freeze

      def initialize(primary_reason, application_choice:)
        @application_choice = application_choice
        @primary_reason = primary_reason
      end

      def primary_reason_text
        translate("#{@primary_reason}.label")
      end

      def reason_details
        withdrawal_reasons.pluck(:reason, :comment).map do |reason, comment|
          if reason.include? PERSONAL_CIRCUMSTANCES_KEY
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
        @withdrawal_reasons ||= @application_choice.draft_withdrawal_reasons.reject do |withdrawal_reason|
          withdrawal_reason.reason.exclude?(@primary_reason)
        end
      end

      def reason_without_further_detail(reason, comment = nil)
        label = translate("#{reason}.label")

        comment.present? ? "#{label}: #{comment}" : label
      end

      def reasons_with_further_detail(reason, comment = nil)
        personal_circumstances_label = translate("#{@primary_reason}.#{PERSONAL_CIRCUMSTANCES_KEY}.label")
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
    end
  end
end

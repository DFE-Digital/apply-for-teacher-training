module CandidateInterface
  module WithdrawalReasons
    class SecondaryReasonsReviewComponent < ViewComponent::Base
      def initialize(primary_reason, application_choice:)
        @application_choice = application_choice
        @primary_reason = primary_reason
      end

      def primary_reason_text
        translate("#{@primary_reason}.label")
      end

      def reason_details
        sorted_reasons.map do |reason, comment|
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
        @withdrawal_reasons ||= @application_choice.draft_withdrawal_reasons.reject do |withdrawal_reason|
          withdrawal_reason.reason.exclude?(@primary_reason)
        end
      end

      def reason_without_further_detail(reason, comment = nil)
        label = translate("#{reason}.label")

        comment.present? ? "#{label}: #{comment}" : label
      end

      def reasons_with_further_detail(reason, comment = nil)
        personal_circumstances_label = translate("#{@primary_reason}.#{personal_circumstances_key}.label")
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

      def sorted_reasons
        reason_keys = WithdrawalReason.find_reason_options(@primary_reason).keys

        withdrawal_reasons.pluck(:reason, :comment).sort do |a, b|
          reason_keys.index(a[0].split('.')[1]) <=> reason_keys.index(b[0].split('.')[1])
        end
      end
    end
  end
end

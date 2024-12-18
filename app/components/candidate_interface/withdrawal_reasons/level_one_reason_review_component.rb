module CandidateInterface
  module WithdrawalReasons
    class LevelOneReasonReviewComponent < ViewComponent::Base
      def initialize(application_choice:, withdrawal_reason:)
        @application_choice = application_choice
        @withdrawal_reason = withdrawal_reason
      end

      def level_one_reason_text
        [translate("#{withdrawal_reason.reason}.label"), withdrawal_reason.comment].join(': ')
      end

    private

      attr_reader :application_choice, :withdrawal_reason

      def translate(string)
        string.gsub!('-', '_')
        I18n.t("candidate_interface.withdrawal_reasons.reasons.#{string}")
      end
    end
  end
end

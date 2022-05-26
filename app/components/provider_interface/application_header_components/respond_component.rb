module ProviderInterface
  module ApplicationHeaderComponents
    class RespondComponent < ApplicationChoiceHeaderComponent
      def make_decision_button_class
        "govuk-!-margin-bottom-0#{' govuk-button--secondary' if set_up_interview?}"
      end
    end
  end
end

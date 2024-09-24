module ProviderInterface
  module ApplicationHeaderComponents
    class OfferAwaitingCandidateResponseComponent < ApplicationChoiceHeaderComponent
      def offer_text
        days = application_choice.days_since_offered

        "You made this offer #{days_since(days)}. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond."
      end
    end
  end
end

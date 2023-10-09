module ProviderInterface
  module ApplicationHeaderComponents
    class OfferWillBeDeclinedByDefaultComponent < ApplicationChoiceHeaderComponent
      def continuous_applications_offer_text
        days = application_choice.days_since_offered

        "You made this offer #{days_since(days)}. Most candidates respond to offers within 15 working days. The candidate will receive reminders to respond."
      end

      def decline_by_default_text
        return unless offer_will_be_declined_by_default?

        if time_is_today_or_tomorrow?(application_choice.decline_by_default_at)
          "at the end of #{date_and_time_today_or_tomorrow(application_choice.decline_by_default_at)}"
        else
          days_remaining = days_until(application_choice.decline_by_default_at.to_date)
          "in #{days_remaining} (#{application_choice.decline_by_default_at.to_fs(:govuk_date_and_time)})"
        end
      end
    end
  end
end

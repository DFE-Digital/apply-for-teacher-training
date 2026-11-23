module CandidateInterface
  module CourseChoices
    class VisaExpiryInterruptionController < BaseController
      before_action :assign_wizard_with_application_choice

      def new
        @find_provider_url = application_choice.find_provider_url
        @find_url_with_visa_filter = "#{find_url}/results?can_sponsor_visa=true"
      end

    private

      def current_step
        :visa_expiry_interruption
      end

      def wizard_controller?
        true
      end
    end
  end
end

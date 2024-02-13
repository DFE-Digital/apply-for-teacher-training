module CandidateInterface
  module References
    class ReminderController < BaseController
      skip_before_action ::UnsuccessfulCarryOverFilter
      skip_before_action ::CarryOverFilter
      skip_before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

      def new; end

      def create
        SendReferenceReminder.call(@reference, flash)
        redirect_to candidate_interface_application_offer_dashboard_path
      end
    end
  end
end

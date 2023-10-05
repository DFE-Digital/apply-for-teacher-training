module CandidateInterface
  module References
    class ReminderController < BaseController
      skip_before_action :redirect_to_dashboard_if_submitted
      skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

      def new; end

      def create
        SendReferenceReminder.call(@reference, flash)
        redirect_to candidate_interface_application_offer_dashboard_path
      end
    end
  end
end

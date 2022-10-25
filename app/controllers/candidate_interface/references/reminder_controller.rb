module CandidateInterface
  module References
    class ReminderController < BaseController
      skip_before_action :redirect_to_dashboard_if_submitted

      def new; end

      def create
        SendReferenceReminder.call(@reference, flash)
        redirect_to candidate_interface_application_offer_dashboard_path
      end
    end
  end
end

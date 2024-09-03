# frozen_string_literal: true

module CandidateInterface
  module ContinuousApplications
    extend ActiveSupport::Concern

    included do
      # CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action UnsuccessfulCarryOverFilter
      before_action CarryOverFilter

    private

      def redirect_to_your_applications_if_submitted
        redirect_to candidate_interface_application_choices_path unless application_choice.unsubmitted?
      end
    end
  end
end

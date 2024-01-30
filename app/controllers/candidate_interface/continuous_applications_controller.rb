module CandidateInterface
  class ContinuousApplicationsController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action UnsuccessfulCarryOverFilter
    before_action CarryOverFilter

  private

    def redirect_to_your_applications_if_submitted
      redirect_to candidate_interface_continuous_applications_choices_path unless application_choice.unsubmitted?
    end
  end
end

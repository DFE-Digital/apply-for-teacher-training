module CandidateInterface
  class ContinuousApplicationsController < CandidateInterfaceController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
    before_action UnsuccessfulCarryOverFilter
    before_action CarryOverFilter
    before_action :verify_continuous_applications

  private

    def redirect_to_your_applications_if_submitted
      redirect_to candidate_interface_continuous_applications_choices_path unless application_choice.unsubmitted?
    end

    def verify_continuous_applications
      render_404 unless current_application&.continuous_applications?
    end
  end
end

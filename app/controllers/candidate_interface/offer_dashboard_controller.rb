module CandidateInterface
  class OfferDashboardController < CandidateInterfaceController
    before_action :redirect_to_completed_dashboard_if_not_accepted
    rescue_from ActiveRecord::RecordNotFound, with: :render_404

    def show
      @application_form = current_application
      @application_choice_with_offer = current_application.application_choices.pending_conditions.first
      @accepted_offer_provider_name = @application_choice_with_offer.provider.name
    end

    def view_reference
      @reference = current_application.application_references.find(params[:id])
    end

  private

    def redirect_to_completed_dashboard_if_not_accepted
      redirect_to candidate_interface_application_complete_path if !any_accepted_offer? || FeatureFlag.inactive?(:new_references_flow)
    end
  end
end

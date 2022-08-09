module CandidateInterface
  class OfferDashboardController < CandidateInterfaceController
    def show
      @application_form = current_application
      @application_choice_with_offer = current_application.application_choices.pending_conditions.first
      @accepted_offer_provider_name = @application_choice_with_offer.provider.name
    end

    def view_reference
      @reference = current_application.application_references.find(params[:id])
    end
  end
end

module CandidateInterface
  class OfferDashboardController < CandidateInterfaceController
    def show
      @application_form = current_application
    end

    def view_reference
      @reference = params[:id]
    end
  end
end

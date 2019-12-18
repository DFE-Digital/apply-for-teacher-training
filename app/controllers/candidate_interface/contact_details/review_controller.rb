module CandidateInterface
  class ContactDetails::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_not_amendable

    def show
      @application_form = current_application
    end
  end
end

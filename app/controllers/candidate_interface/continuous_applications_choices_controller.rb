module CandidateInterface
  class ContinuousApplicationsChoicesController < ContinuousApplicationsController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
    end
  end
end

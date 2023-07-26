module CandidateInterface
  class ContinuousApplicationsChoicesController < ContinuousApplicationsController
    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
    end
  end
end

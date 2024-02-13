module CandidateInterface
  class ContinuousApplicationsChoicesController < ContinuousApplicationsController
    before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

    def index
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_choices = CandidateInterface::SortApplicationChoices.call(
        application_choices:
          current_application
            .application_choices
            .includes(:course, :site, :provider, :current_course, :current_course_option, :interviews)
            .includes(offer: :conditions),
      )
    end
  end
end

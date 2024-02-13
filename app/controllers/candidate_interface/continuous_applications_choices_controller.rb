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

      @application_types = %w[all offers_received draft unsuccessful in_progress withdraw declined]
      # ask Laura about order of withdrawn / declined
      # todo: see when user tries to force non existent application type
      if params[:application_type] && params[:application_type] != 'all'
        @application_choices = @application_choices.select { |ac| ac.application_choices_group == @application_types.index(params[:application_type]) }
      end
    end
  end
end

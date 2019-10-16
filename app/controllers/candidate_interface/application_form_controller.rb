module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    def show
      redirect_to candidate_interface_application_form_path if params[:token]
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_candidate.current_application)
    end

    def review
      personal_details_form = PersonalDetailsForm.build_from_application(
        current_candidate.current_application,
        )
      @personal_details_review = PersonalDetailsReviewPresenter.new(personal_details_form)
    end

    def submit_show
      @application_form = current_candidate.current_application
    end

    def submit
      @application_form = current_candidate.current_application

      # TODO: improve and move this into a service
      application_not_submitted = @application_form.application_choices.first.status != 'application_complete'
      if application_not_submitted
        @application_form.application_choices.each do |application_choice|
          ApplicationStateChange.new(application_choice).submit!
        end
      end

      render :success
    end
  end
end

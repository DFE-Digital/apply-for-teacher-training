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

      SubmitApplication.new(@application_form.application_choices).call

      redirect_to candidate_interface_application_submit_success_path
    end

    def submit_success; end
  end
end

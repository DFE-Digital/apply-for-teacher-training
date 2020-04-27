module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted, only: %i[show review]
    before_action :redirect_to_application_form_unless_submitted, only: %i[review_submitted complete submit_success]

    def show
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)
      @application_form = current_application
    end

    def before_you_start; end

    def review
      redirect_to candidate_interface_application_complete_path if current_application.submitted?
      @application_form = current_application
    end

    def edit
      @editable_days = TimeLimitConfig.edit_by
      render :edit_by_support
    end

    def complete
      @application_form = current_application
    end

    def submit_show
      @application_form = current_application
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if @application_form_presenter.ready_to_submit?
        @further_information_form = FurtherInformationForm.new
      else
        @errors = @application_form_presenter.section_errors
        @application_choice_errors = @application_form_presenter.application_choice_errors

        render :review
      end
    end

    def submit
      @further_information_form = FurtherInformationForm.new(further_information_params)

      if @further_information_form.save(current_application)
        SubmitApplication.new(current_application).call

        redirect_to candidate_interface_application_submit_success_path
      else
        track_validation_error(@further_information_form)
        render :submit_show
      end
    end

    def submit_success
      @support_reference = current_application.support_reference
      @editable_days = TimeLimitConfig.edit_by
    end

    def review_submitted
      @application_form = current_application
    end

  private

    def further_information_params
      params.require(:candidate_interface_further_information_form).permit(
        :further_information,
        :further_information_details,
      )
        .transform_values(&:strip)
    end
  end
end

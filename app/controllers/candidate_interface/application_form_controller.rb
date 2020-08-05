module CandidateInterface
  class ApplicationFormController < CandidateInterfaceController
    def before_you_start; end

    def start_apply_again
      render_404 and return unless FeatureFlag.active?('apply_again')
    end

    def apply_again
      render_404 and return unless FeatureFlag.active?('apply_again')

      DuplicateApplication.new(current_application).duplicate
      flash[:success] = 'Your new application is ready for editing'
      redirect_to candidate_interface_before_you_start_path
    end

    def edit
      redirect_to candidate_interface_application_complete_path and return unless current_application.can_edit_after_submission?

      @application_form = current_application
      render :edit_by_support
    end

    def submit_show
      @application_form = current_application
      @application_form_presenter = CandidateInterface::ApplicationFormPresenter.new(current_application)

      if @application_form_presenter.ready_to_submit?
        @further_information_form = FurtherInformationForm.new
      else
        @errors = @application_form_presenter.section_errors
        @application_choice_errors = @application_form_presenter.application_choice_errors

        render 'candidate_interface/unsubmitted_application_form/review'
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

    def review_previous_application
      @application_form = current_candidate.application_forms.find(params[:id])
      @review_previous_application = true

      render 'candidate_interface/submitted_application_form/review_submitted'
    rescue ActiveRecord::RecordNotFound
      render_404
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

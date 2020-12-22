module CandidateInterface
  class TrainingWithADisabilityController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
    end

    def edit
      @training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(current_application)
    end

    def update
      @training_with_a_disability_form = TrainingWithADisabilityForm.new(training_with_a_disability_params)

      if @training_with_a_disability_form.save(current_application)
        current_application.update!(training_with_a_disability_completed: false)

        redirect_to candidate_interface_training_with_a_disability_show_path
      else
        track_validation_error(@training_with_a_disability_form)
        render :edit
      end
    end

    def complete
      current_application.update!(application_form_params)

      redirect_to candidate_interface_application_form_path
    end

  private

    def training_with_a_disability_params
      strip_whitespace params
        .require(:candidate_interface_training_with_a_disability_form)
        .permit(:disclose_disability, :disability_disclosure)
    end

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:training_with_a_disability_completed)
    end
  end
end

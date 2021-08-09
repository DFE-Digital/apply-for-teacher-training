module CandidateInterface
  class TrainingWithADisabilityController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(completed: current_application.training_with_a_disability_completed)
    end

    def new
      @training_with_a_disability_form = TrainingWithADisabilityForm.new
    end

    def create
      @training_with_a_disability_form = TrainingWithADisabilityForm.new(training_with_a_disability_params)

      if @training_with_a_disability_form.save(current_application)
        redirect_to candidate_interface_training_with_a_disability_show_path
      else
        track_validation_error(@training_with_a_disability_form)
        render :new
      end
    end

    def edit
      @training_with_a_disability_form = TrainingWithADisabilityForm.build_from_application(current_application)
      @return_to = return_to_after_edit(default: candidate_interface_training_with_a_disability_show_path)
    end

    def update
      @training_with_a_disability_form = TrainingWithADisabilityForm.new(training_with_a_disability_params)
      @return_to = return_to_after_edit(default: candidate_interface_training_with_a_disability_show_path)

      if @training_with_a_disability_form.save(current_application)
        redirect_to @return_to[:back_path]
      else
        track_validation_error(@training_with_a_disability_form)
        render :edit
      end
    end

    def complete
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(section_complete_form_params)

      if @section_complete_form.save(current_application, :training_with_a_disability_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def training_with_a_disability_params
      strip_whitespace params
        .require(:candidate_interface_training_with_a_disability_form)
        .permit(:disclose_disability, :disability_disclosure)
    end

    def section_complete_form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end

module CandidateInterface
  class ContactDetails::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(
        completed: current_application.contact_details_completed,
      )
    end

    def complete
      @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])

      if @section_complete_form.save(current_application, :contact_details_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def application_form_params
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end

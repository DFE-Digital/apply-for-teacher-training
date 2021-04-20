module CandidateInterface
  class Gcse::ReviewController < Gcse::BaseController
    before_action :set_field_name
    before_action :render_application_feedback_component, except: :complete

    def show
      @application_form = current_application
      @application_qualification = current_qualification
      @section_complete_form = SectionCompleteForm.new(
        completed: current_application.send(@field_name),
      )
    end

    def complete
      @application_form = current_application
      @application_qualification = current_qualification
      @section_complete_form = SectionCompleteForm.new(completed: application_form_params[:completed])

      if @application_qualification.incomplete_gcse_information? && !@application_qualification.missing_qualification?
        flash[:warning] = 'You cannot mark this section complete with incomplete GCSE information.'
        render :show
      elsif @section_complete_form.save(current_application, @field_name.to_sym)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def set_field_name
      @field_name = "#{@subject}_gcse_completed"
    end

    def application_form_params
      strip_whitespace params.require(:candidate_interface_section_complete_form).permit(:completed)
    end
  end
end

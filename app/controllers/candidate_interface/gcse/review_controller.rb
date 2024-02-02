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

      if @application_qualification.incomplete_gcse_information? &&
         ActiveModel::Type::Boolean.new.cast(@section_complete_form.completed)
        flash[:warning] = 'You cannot mark this section complete with incomplete GCSE information.'
        redirect_to candidate_interface_gcse_review_path(subject: @subject)
      elsif @section_complete_form.save(current_application, @field_name.to_sym)
        redirect_to candidate_interface_continuous_applications_details_path
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
      strip_whitespace params.fetch(:candidate_interface_section_complete_form, {}).permit(:completed)
    end
  end
end

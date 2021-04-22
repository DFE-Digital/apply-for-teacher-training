module CandidateInterface
  class OtherQualifications::ReviewController < OtherQualifications::BaseController
    def show
      redirect_to candidate_interface_other_qualification_type_path and return if current_application.application_qualifications.other.blank? && !current_application.no_other_qualifications

      @application_form = current_application
      @section_complete_form = SectionCompleteForm.new(
        completed: current_application.other_qualifications_completed,
      )
    end

    def complete
      @application_form = current_candidate.current_application
      @section_complete_form = SectionCompleteForm.new(application_form_params)

      if section_marked_as_complete? && there_are_incomplete_qualifications?
        flash[:warning] = 'You must fill in all your qualifications to complete this section'

        render :show
      elsif @section_complete_form.save(current_application, :other_qualifications_completed)
        redirect_to candidate_interface_application_form_path
      else
        track_validation_error(@section_complete_form)
        render :show
      end
    end

  private

    def application_form_params
      strip_whitespace params.require(:candidate_interface_section_complete_form).permit(:completed)
    end

    def there_are_incomplete_qualifications?
      current_application.application_qualifications.other.select(&:incomplete_other_qualification?).present?
    end

    def section_marked_as_complete?
      application_form_params[:completed] == 'true'
    end
  end
end

module CandidateInterface
  class OtherQualifications::ReviewController < OtherQualifications::BaseController
    def show
      redirect_to candidate_interface_other_qualification_type_path and return if current_application.application_qualifications.other.blank? && !current_application.no_other_qualifications

      @application_form = current_application
    end

    def complete
      @application_form = current_candidate.current_application

      if section_marked_as_complete? && there_are_incomplete_qualifications?
        flash[:warning] = 'You must fill in all your qualifications to complete this section'

        render :show
      else
        @application_form.update!(application_form_params)

        redirect_to candidate_interface_application_form_path
      end
    end

  private

    def application_form_params
      strip_whitespace params.require(:application_form).permit(:other_qualifications_completed)
    end

    def there_are_incomplete_qualifications?
      current_application.application_qualifications.other.select(&:incomplete_other_qualification?).present?
    end

    def section_marked_as_complete?
      application_form_params[:other_qualifications_completed] == 'true'
    end
  end
end

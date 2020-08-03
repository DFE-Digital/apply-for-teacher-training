module CandidateInterface
  class OtherQualifications::ReviewController < CandidateInterfaceController
    before_action :redirect_to_dashboard_if_submitted

    def show
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
      params.require(:application_form).permit(:other_qualifications_completed)
        .transform_values(&:strip)
    end

    def there_are_incomplete_qualifications?
      current_application.application_qualifications.other.select(&:incomplete_other_qualification?).present?
    end

    def section_marked_as_complete?
      application_form_params[:other_qualifications_completed] == 'true'
    end
  end
end

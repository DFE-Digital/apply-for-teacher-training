module CandidateInterface
  class OtherQualifications::ReviewController < OtherQualifications::BaseController
    def show
      redirect_to candidate_interface_other_qualification_type_path and return if current_application.application_qualifications.other.blank?

      # This to ensure that old state is not merged accidentally when
      # the user goes on to edit a qualification
      intermediate_data_service.clear_state!

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

    def intermediate_data_service
      IntermediateDataService.new(
        WizardStateStores::RedisStore.new(
          key: persistence_key_for_current_user,
        ),
      )
    end
  end
end

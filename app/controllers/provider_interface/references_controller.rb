module ProviderInterface
  class ReferencesController < ProviderInterfaceController
    before_action :set_application_choice, :redirect_if_unsuccessful, :set_references

    def index
      @provider_can_make_decisions =
        current_provider_user.authorisation.can_make_decisions?(application_choice: @application_choice,
                                                                course_option: @application_choice.current_course_option)

      @provider_can_set_up_interviews = current_provider_user.authorisation.can_set_up_interviews?(
        application_choice: @application_choice,
        course_option: @application_choice.current_course_option,
      )
    end

  private

    def redirect_if_unsuccessful
      redirect_to provider_interface_application_choice_path(@application_choice) if @application_choice.application_unsuccessful?
    end

    def set_references
      @references = @application_choice.application_form.application_references
      @references = @references.selected unless new_references_flow?
    end

    def new_references_flow?
      @application_choice.application_form.recruitment_cycle_year > ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR
    end
  end
end

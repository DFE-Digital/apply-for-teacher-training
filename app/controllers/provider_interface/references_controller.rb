module ProviderInterface
  class ReferencesController < ProviderInterfaceController
    before_action :set_application_choice, :set_references

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

    def set_references
      @references = @application_choice.application_form.application_references
      @references = @references.selected unless @application_choice.application_form.show_new_reference_flow?
    end
  end
end

module ProviderInterface
  class ReferencesController < ProviderInterfaceController
    before_action :set_application_choice

    def index
      @references = @application_choice.application_form.application_references

      @provider_can_make_decisions =
        current_provider_user.authorisation.can_make_decisions?(application_choice: @application_choice,
                                                                course_option: @application_choice.current_course_option)
    end
  end
end

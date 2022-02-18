module ProviderInterface
  class CoursesController < ProviderInterfaceController
    before_action :set_application_choice

    def edit
      redirect_to provider_interface_application_choice_course_path(@application_choice)
    end

  private

    def change_course_store
      key = "change_course_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def action
      'back' if !!params[:back]
    end

    def available_providers
      query_service.available_providers
    end

    def query_service
      @query_service ||= GetChangeOfferOptions.new(
        user: current_provider_user,
        current_course: @application_choice.current_course,
      )
    end
  end
end

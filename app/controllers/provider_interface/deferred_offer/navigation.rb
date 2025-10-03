module ProviderInterface::DeferredOffer::Navigation
  extend ActiveSupport::Concern

  included do
    helper_method :return_to_review?

  private

    def return_to_review?
      params[:return_to] == 'review'
    end

    def next_step_path(deferred_offer_confirmation)
      deferred_offer_confirmation.valid?(:submit)

      if deferred_offer_confirmation.errors.include?(:course)
        return provider_interface_deferred_offer_course_path(application_choice)
      end

      if deferred_offer_confirmation.errors.include?(:location)
        return provider_interface_deferred_offer_location_path(application_choice)
      end

      if deferred_offer_confirmation.errors.include?(:study_mode)
        return provider_interface_deferred_offer_study_mode_path(application_choice)
      end

      provider_interface_deferred_offer_check_path(application_choice)
    end

    def offer
      application_choice.offer
    end

    def application_choice
      @application_choice ||= GetApplicationChoicesForProviders.call(
        providers: current_provider_user.providers,
      ).find(params.require(:application_choice_id))
    end
  end
end

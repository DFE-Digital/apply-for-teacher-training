module ProviderInterface
  class ChangeOfferComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :change_offer_form, :application_choice, :providers, :completion_url, :completion_method

    def initialize(change_offer_form:, providers:, completion_url:, completion_method:)
      @change_offer_form = change_offer_form
      @application_choice = change_offer_form.application_choice
      @providers = providers
      @completion_url = completion_url
      @completion_method = completion_method
      set_entry_from_step
    end

    def sub_component
      step_to_render = \
        change_offer_form.valid? ? change_offer_form.step : change_offer_form.previous_step
      get_component_for_step step_to_render
    end

    def set_entry_from_step
      change_offer_form.entry ||= change_offer_form.step
    end

  private

    def setup_component(component)
      if component == ProviderInterface::ChangeOffer::ConfirmComponent
        component.new(
          change_offer_form: change_offer_form,
          providers: providers,
          completion_url: completion_url,
          completion_method: completion_method,
        )
      else
        component.new(
          change_offer_form: change_offer_form,
          providers: providers,
        )
      end
    end

    def get_component_for_step(step)
      case step
      when :confirm
        setup_component ProviderInterface::ChangeOffer::ConfirmComponent
      when :course_option
        setup_component ProviderInterface::ChangeOffer::ChangeLocationComponent
      when :course
        setup_component ProviderInterface::ChangeOffer::ChangeCourseComponent
      when :provider
        setup_component ProviderInterface::ChangeOffer::ChangeProviderComponent
      end
    end
  end
end

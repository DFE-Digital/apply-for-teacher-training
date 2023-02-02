module ProviderInterface
  class SkeController < ProviderInterfaceController
    before_action :set_application_choice

    def new
      @wizard = OfferWizard.build_from_application_choice(
        offer_store,
        @application_choice,
        provider_user_id: current_provider_user.id,
        current_step: ske_flow_step,
        decision: :default,
        action:,
      )

      assign_new_attributes
      @wizard.save_state!
    end

    def create
      @wizard = OfferWizard.new(offer_store, decision: :make_offer, current_step: ske_flow_step)
      @wizard.assign_attributes(ske_flow_params)

      if @wizard.valid_for_current_step?
        @wizard.save_state!

        redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
      else
        track_validation_error(@wizard)
        render 'new'
      end
    end

  private

    def assign_new_attributes; end

    def offer_wizard_params
      params[:provider_interface_offer_wizard] || ActionController::Parameters.new
    end

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key:)
    end

    def action
      'back' if !!params[:back]
    end

    def language_ske?
      @wizard.language_course?
    end
    helper_method :language_ske?
  end
end

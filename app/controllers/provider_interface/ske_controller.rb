module ProviderInterface
  class SkeController < ProviderInterfaceController
    before_action :set_application_choice

    def new
      @wizard = OfferWizard.new(offer_store, decision: :make_offer, current_step: ske_flow_step)
      @wizard.save_state!
    end

    def edit
      @wizard = OfferWizard.new(offer_store, decision: :change_offer, current_step: ske_flow_step)
      @wizard.save_state!
    end

    def create
      @wizard = OfferWizard.new(offer_store, decision: :make_offer, current_step: ske_flow_step)

      yield @wizard if block_given?
      @wizard.assign_attributes(ske_flow_params)

      if @wizard.errors.empty? && @wizard.valid_for_current_step?
        @wizard.save_state!

        redirect_to [:new, :provider_interface, @application_choice, :offer, @wizard.next_step]
      else
        track_validation_error(@wizard)
        render 'new'
      end
    end

    def update
      @wizard = OfferWizard.new(offer_store, decision: :change_offer, current_step: ske_flow_step)

      yield @wizard if block_given?
      @wizard.assign_attributes(ske_flow_params)

      if @wizard.errors.empty? && @wizard.valid_for_current_step?
        @wizard.save_state!

        redirect_to [:edit, :provider_interface, @application_choice, :offer, @wizard.next_step]
      else
        track_validation_error(@wizard)
        render 'new'
      end
    end

  private

    def assign_create_attributes; end

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

    def physics_ske?
      @wizard.physics_course?
    end
    helper_method :physics_ske?
  end
end

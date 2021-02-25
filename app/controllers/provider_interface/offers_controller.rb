module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def check
      @wizard = OfferWizard.new(offer_store, offer_conditions_params.merge!(current_step: 'check'))
      @wizard.save_state!

      render :check
    end

    def create
      @wizard = OfferWizard.new(offer_store)

      if @wizard.valid?
        MakeAnOffer.new(actor: current_provider_user,
                        application_choice: @application_choice,
                        course_option: @wizard.course_option,
                        offer_conditions: @wizard.conditions).save
        flash[:info] = 'Offer successfully created.'
        redirect_to provider_interface_application_choice_offer_path(@application_choice)
      else
        @wizard.clear_state!
        flash[:warning] = 'Something went wrong. Please start again'
        redirect_to provider_interface_application_choice_respond_path(@application_choice)
      end
    end

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end

    def offer_conditions_params
      params.require(:provider_interface_offer_wizard).permit(conditions: [])
    end
  end
end

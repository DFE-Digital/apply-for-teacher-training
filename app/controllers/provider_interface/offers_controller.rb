module ProviderInterface
  class OffersController < ProviderInterfaceController
    before_action :set_application_choice
    before_action :requires_make_decisions_permission

    def create
      @wizard = OfferWizard.new(offer_store)
      if @wizard.valid?
        MakeOffer.new(actor: current_provider_user,
                      application_choice: @application_choice,
                      course_option: @wizard.course_option,
                      conditions: @wizard.conditions).save!
        @wizard.clear_state!

        flash[:success] = t('.success')
        redirect_to provider_interface_application_choice_offer_path(@application_choice)
      else
        @wizard.clear_state!

        flash[:warning] = t('.failure')
        redirect_to new_provider_interface_application_choice_decision_path(@application_choice)
      end
    end

  private

    def offer_store
      key = "offer_wizard_store_#{current_provider_user.id}_#{@application_choice.id}"
      WizardStateStores::RedisStore.new(key: key)
    end
  end
end

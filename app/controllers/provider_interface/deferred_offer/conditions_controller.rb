class ProviderInterface::DeferredOffer::ConditionsController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def edit
    @conditions_form = DeferredOfferConfirmation::ConditionsForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )
  end

  def update
    @conditions_form = DeferredOfferConfirmation::ConditionsForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )

    if @conditions_form.update(conditions_form_params)
      redirect_to provider_interface_application_choice_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def conditions_form_params
    params.expect(deferred_offer_confirmation_conditions_form: [:conditions_status])
  end
end

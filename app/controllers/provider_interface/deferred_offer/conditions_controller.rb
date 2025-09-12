class ProviderInterface::DeferredOffer::ConditionsController < ProviderInterface::ProviderInterfaceController
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
      redirect_to provider_interface_deferred_offer_check_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def conditions_form_params
    params.expect(deferred_offer_confirmation_conditions_form: [:conditions_status])
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

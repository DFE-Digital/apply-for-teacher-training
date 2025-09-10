class ProviderInterface::DeferredOffer::LocationController < ProviderInterface::ProviderInterfaceController
  def edit
    @location_form = DeferredOfferConfirmation::LocationForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )
  end

  def update
    @location_form = DeferredOfferConfirmation::LocationForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )

    if @location_form.update(location_form_params)
      redirect_to provider_interface_deferred_offer_check_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def location_form_params
    params.expect(deferred_offer_confirmation_location_form: %i[site_id site_id_raw])
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

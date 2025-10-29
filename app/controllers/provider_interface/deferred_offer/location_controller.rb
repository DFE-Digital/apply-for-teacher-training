class ProviderInterface::DeferredOffer::LocationController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def edit
    @location_form = DeferredOfferConfirmation::LocationForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )
  end

  def update
    @location_form = DeferredOfferConfirmation::LocationForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )

    if @location_form.update(location_form_params)
      redirect_to next_step_path(@location_form)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def location_form_params
    params.expect(deferred_offer_confirmation_location_form: %i[site_id site_id_raw])
  end
end

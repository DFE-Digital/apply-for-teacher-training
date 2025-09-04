class ProviderInterface::DeferredOffer::StudyModeController < ProviderInterface::ProviderInterfaceController
  def edit
    @study_mode_form = DeferredOfferConfirmation::StudyModeForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )
  end

  def update
    @study_mode_form = DeferredOfferConfirmation::StudyModeForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )

    if @study_mode_form.update(study_mode_form_params)
      redirect_to provider_interface_deferred_offer_check_path(application_choice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def study_mode_form_params
    params.expect(deferred_offer_confirmation_study_mode_form: [:study_mode])
  end

  def offer
    application_choice.offer
  end

  def application_choice
    GetApplicationChoicesForProviders.call(
      providers: current_provider_user.providers,
    ).find(params.require(:application_choice_id))
  end
end

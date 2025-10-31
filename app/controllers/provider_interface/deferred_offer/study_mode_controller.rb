class ProviderInterface::DeferredOffer::StudyModeController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def edit
    @study_mode_form = DeferredOfferConfirmation::StudyModeForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )
  end

  def update
    @study_mode_form = DeferredOfferConfirmation::StudyModeForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer:,
    )

    if @study_mode_form.update(study_mode_form_params)
      redirect_to next_step_path(@study_mode_form)
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def study_mode_form_params
    params.expect(deferred_offer_confirmation_study_mode_form: [:study_mode])
  end
end

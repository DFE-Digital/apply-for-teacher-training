class ProviderInterface::DeferredOffer::ConditionsController < ProviderInterface::ProviderInterfaceController
  def show
    @conditions_form = DeferredOfferConfirmation::ConditionsForm.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )
  end

  def create; end

private

  def offer
    application_choice.offer
  end

  def application_choice
    @application_choice ||= GetApplicationChoicesForProviders.call(
      providers: current_provider_user.providers,
    ).find(params.require(:application_choice_id))
  end
end

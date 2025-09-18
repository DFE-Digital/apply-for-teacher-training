class ProviderInterface::DeferredOffer::RootController < ProviderInterface::ProviderInterfaceController
  include ProviderInterface::DeferredOffer::Navigation

  def show
    deferred_offer_confirmation = DeferredOfferConfirmation.find_or_initialize_by(
      provider_user: current_provider_user,
      offer: offer,
    )

    redirect_to next_step_path(deferred_offer_confirmation)
  end
end

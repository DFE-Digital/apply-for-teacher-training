module ConfirmedDeferredOfferInfo
  def schema
    super.deep_merge!(attributes: {
      offer: {
        offer_deferred_at: application_choice.offer_deferred_at,
        status_before_deferral: application_choice.status_before_deferral,
      },
    })
  end
end

module DeferredOfferAPIData
  def schema
    return super if application_choice.offer.nil?

    super.deep_merge!({
      attributes: {
        offer: {
          status_before_deferral: application_choice.status_before_deferral,
          offer_deferred_at: application_choice.offer_deferred_at&.iso8601,
        },
      },
    })
  end
end

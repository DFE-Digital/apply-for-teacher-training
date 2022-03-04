module VendorAPI::ApplicationPresenter::DeferredOffer
  def schema
    return super if application_choice.offer.nil?

    super.deep_merge!({
      attributes: {
        offer: {
          status_before_deferral: application_choice.status_before_deferral,
          offer_deferred_at: application_choice.offer_deferred_at&.iso8601,
          deferred_to_recruitment_cycle_year: deferred_to_recruitment_cycle_year,
        },
      },
    })
  end

  def deferred_to_recruitment_cycle_year
    return unless application_choice.offer_deferred?

    application_choice.current_recruitment_cycle_year + 1
  end
end

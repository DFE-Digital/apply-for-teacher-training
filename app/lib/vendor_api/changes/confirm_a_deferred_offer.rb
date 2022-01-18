module VendorAPI
  module Changes
    class ConfirmADeferredOffer < VersionChange
      description \
        "Confirm a deferred offer.\n" \
        'Confirms a deferred offer from the previous cycle to the current one.'

      action ConfirmDeferredOffersController, :create

      resource ApplicationPresenter, [ConfirmedDeferredOfferInfo]
    end
  end
end

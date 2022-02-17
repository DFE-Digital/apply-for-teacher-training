module VendorAPI
  module Changes
    class ConfirmDeferredOffer < VersionChange
      description \
        "Confirm a deferred offer.\n" \
        'Confirms a deferred offer from the previous cycle to the current one.'

      action ConfirmDeferredOffersController, :create
    end
  end
end

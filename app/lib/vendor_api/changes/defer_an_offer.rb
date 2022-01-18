module VendorAPI
  module Changes
    class DeferAnOffer < VersionChange
      description \
        "Defer an existing offer.\n" \
        'This will transition the application to the deferred offer state.'

      action DeferredOffersController, :create

      resource ApplicationPresenter, [ApplicationTransitioningModule]
    end
  end
end

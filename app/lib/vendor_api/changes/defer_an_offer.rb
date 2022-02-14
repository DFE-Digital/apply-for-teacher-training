module VendorAPI
  module Changes
    class DeferAnOffer < VersionChange
      description 'Defers an offer to the next cycle. ' \
                  'The application will transition to the offer_deferred status and the fields ' \
                  'offer_deferred_at and status_before_deferral will be populated.'

      action DeferredOffersController, :create

      resource ApplicationPresenter, [ApplicationPresenter::DeferredOffer]
    end
  end
end

module VendorAPI
  module Changes
    module V18
      class VisaExpiry < VersionChange
        description 'Add visa expiry to the application attributes'

        resource ApplicationPresenter, [ApplicationPresenter::VisaExpiry]
      end
    end
  end
end

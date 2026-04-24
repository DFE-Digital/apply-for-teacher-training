module VendorAPI
  module Changes
    module V18
      class LengthOfResidency < VersionChange
        description 'Add country residency information to the application attributes'

        resource ApplicationPresenter, [ApplicationPresenter::LengthOfResidency]
      end
    end
  end
end

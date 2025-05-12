module VendorAPI
  module Changes
    module V16
      class AddInactiveToApplicationAttributeStatuses < VersionChange
        description 'Add inactive to the application attributes'
        resource ApplicationPresenter, [ApplicationPresenter::AddInactiveStatus]
      end
    end
  end
end

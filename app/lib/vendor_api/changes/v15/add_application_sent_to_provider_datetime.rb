module VendorAPI
  module Changes
    module V15
      class AddApplicationSentToProviderDatetime < VersionChange
        description 'Add the date and time that the application was sent to the provider.'

        resource ApplicationPresenter, [ApplicationPresenter::AddSentToProviderDatetime]
      end
    end
  end
end

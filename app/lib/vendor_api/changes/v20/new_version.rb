module VendorAPI
  module Changes
    module V20
      class NewVersion < VersionChange
        description 'test'

        resource ApplicationPresenter
      end
    end
  end
end

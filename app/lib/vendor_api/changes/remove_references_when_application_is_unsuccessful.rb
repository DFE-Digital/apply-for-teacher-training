module VendorAPI
  module Changes
    class RemoveReferencesWhenApplicationIsUnsuccessful < VersionChange
      description "Don't show references when application is unsuccessful"

      resource ApplicationPresenter
    end
  end
end

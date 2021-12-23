module VendorAPI
  module Changes
    class RetrieveApplications < VersionChange
      description \
        'This endpoint can be used to retrieve applications for the authenticating provider. ' \
        'Applications are returned with the most recently updated ones first.' \
        'Use the `since` parameter to limit the number of results. This is intended to make it possible ' \
        'to check for new or updated applications regularly'

      action ApplicationsController, :index

      resource ApplicationPresenter
    end
  end
end

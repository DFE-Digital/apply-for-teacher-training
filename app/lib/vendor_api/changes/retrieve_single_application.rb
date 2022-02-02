module VendorAPI
  module Changes
    class RetrieveSingleApplication < VersionChange
      description 'Get single application'

      action ApplicationsController, :show
      resource SingleApplicationPresenter
    end
  end
end

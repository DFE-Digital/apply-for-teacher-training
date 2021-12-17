module VendorAPI
  module Changes
    class RetrieveSingleApplication < VersionChange
      description 'Get single application'

      action ApplicationsController, :show
    end
  end
end

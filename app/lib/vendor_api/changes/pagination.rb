module VendorAPI
  module Changes
    class Pagination < VersionChange
      description 'Includes pagination'

      resource MetaPresenter
      resource MultipleApplicationsPresenter, [VendorAPI::Pagination]
    end
  end
end

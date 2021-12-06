module VendorAPI
  module Changes
    class Pagination < VersionChange
      description 'Includes pagination'

      resource MultipleApplicationsPresenter, [PaginationAPIData]
    end
  end
end

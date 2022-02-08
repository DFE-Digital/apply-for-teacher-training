module VendorAPI
  module Changes
    class Pagination < VersionChange
      description 'Includes pagination'

      resource MetaPresenter
      resource MultipleApplicationsPresenter, [PaginationAPIData]
    end
  end
end

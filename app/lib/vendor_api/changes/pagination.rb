module VendorAPI
  module Changes
    class Pagination < VersionChange
      description 'Includes pagination'

      resource MetaPresenter
      resource MultipleApplicationsPresenter, [MultipleApplicationsPresenter::Pagination]
    end
  end
end

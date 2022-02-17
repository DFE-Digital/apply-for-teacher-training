module VendorAPI
  module Changes
    class Pagination < VersionChange
      description 'Includes pagination in multiple applications response'

      resource MetaPresenter
      resource MultipleApplicationsPresenter, [MultipleApplicationsPresenter::Pagination]
    end
  end
end

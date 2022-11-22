module VendorAPI
  module Changes
    module WorkHistory
      class AddStartAndEndMonth < VersionChange
        description 'Add `start_month` and `end_month` objects to work and volunteering experience entries, deprecate `start_date` and `end_date`'

        resource ApplicationPresenter
      end
    end
  end
end

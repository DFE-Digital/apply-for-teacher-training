module VendorAPI
  module Changes
    class GcseGrades < VersionChange
      description 'An array of possible GCSE grades including double-award grades.'

      action ReferenceDataController, :gcse_grades
    end
  end
end

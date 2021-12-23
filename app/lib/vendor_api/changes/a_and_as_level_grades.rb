module VendorAPI
  module Changes
    class AAndAsLevelGrades < VersionChange
      description 'An array of possible A and AS level grades.'

      action ReferenceDataController, :a_and_as_level_grades
    end
  end
end

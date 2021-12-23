module VendorAPI
  module Changes
    class AAndAsLevelSubjects < VersionChange
      description \
        "An array of possible A and AS level subjects.\n" \
        "Candidates are offered these in an autocomplete when filling in the form, \n" \
        'but are also able to provide free-text responses.'

      action ReferenceDataController, :a_and_as_level_subjects
    end
  end
end

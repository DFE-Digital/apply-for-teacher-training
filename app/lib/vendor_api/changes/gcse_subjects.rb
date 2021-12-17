module VendorAPI
  module Changes
    class GcseSubjects < VersionChange
      description \
        "An array of possible GCSE subjects.\n" \
        'Candidates are offered these in an autocomplete when filling in the form, ' \
        'but are also able to provide free-text responses.'

      action ReferenceDataController, :gcse_subjects
    end
  end
end

module VendorAPI
  module Changes
    class RegenerateTestData < VersionChange
      description \
        "Regenerate test data \n" \
        'This endpoint has been deprecated'

      action TestDataController, :regenerate
    end
  end
end

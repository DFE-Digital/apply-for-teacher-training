module VendorAPI
  module Changes
    class ClearTestData < VersionChange
      description \
        "Clear test data \n" \
        'Deletes ALL application data for the current provider regardless of how it was created.' \
        'Only available on the Sandbox. EXPERIMENTAL — this endpoint may change or disappear.'

      action TestDataController, :clear!
    end
  end
end

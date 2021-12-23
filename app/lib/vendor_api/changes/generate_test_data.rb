module VendorAPI
  module Changes
    class GenerateTestData < VersionChange
      description \
        "Generate test data \n" \
        'Submits a request to generate n new applications, defaulting to 100 applications with one course choice per' \
        'application. The applications are generated asynchronously, and will appear once they have been generated.' \
        'Does not change existing data. Only available on the Sandbox. EXPERIMENTAL — this endpoint may change or disappear.'

      action TestDataController, :generate
    end
  end
end

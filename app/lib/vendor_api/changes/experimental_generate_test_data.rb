module VendorAPI
  module Changes
    class ExperimentalGenerateTestData < VersionChange
      description 'Experimental Generate test data'

      action TestDataController, :experimental_endpoint_moved
    end
  end
end

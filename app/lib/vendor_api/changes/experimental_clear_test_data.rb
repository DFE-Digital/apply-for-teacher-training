module VendorAPI
  module Changes
    class ExperimentalClearTestData < VersionChange
      description 'Experimental Clear test data'

      action TestDataController, :experimental_endpoint_moved
    end
  end
end

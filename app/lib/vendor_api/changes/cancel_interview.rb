module VendorAPI
  module Changes
    class CancelInterview < VersionChange
      description 'Cancel interviews via the API.'

      action InterviewsController, :cancel
    end
  end
end

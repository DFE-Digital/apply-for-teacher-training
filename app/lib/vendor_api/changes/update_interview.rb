module VendorAPI
  module Changes
    class UpdateInterview < VersionChange
      description 'Update interviews via the API.'

      action InterviewsController, :update
    end
  end
end

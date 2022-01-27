module VendorAPI
  module Changes
    class CreateInterview < VersionChange
      description 'Create interviews via the API.'

      action InterviewsController, :create
    end
  end
end

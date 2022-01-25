module VendorAPI
  module Changes
    class AddInterviewsToApplication < VersionChange
      description 'Include interviews in application json responses.'

      resource InterviewPresenter
      resource ApplicationPresenter, [AddInterviewsToApplicationAPIData]
    end
  end
end

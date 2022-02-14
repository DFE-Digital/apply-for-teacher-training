module VendorAPI
  module Changes
    class InterviewsForApplication < VersionChange
      description 'Include interviews in application json responses.'

      resource InterviewPresenter
      resource ApplicationPresenter, [ApplicationPresenter::Interviews]
    end
  end
end

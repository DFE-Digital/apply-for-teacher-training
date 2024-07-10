module VendorAPI
  module Changes
    module V15
      class AddReferenceFeedbackProvidedAtDatetime < VersionChange
        description 'Add the date and time that feedback was provided for the Reference.'

        resource ReferencePresenter, [ReferencePresenter::FeedbackProvidedAt]
      end
    end
  end
end

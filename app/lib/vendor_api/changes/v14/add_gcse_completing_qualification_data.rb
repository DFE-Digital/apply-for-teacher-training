module VendorAPI
  module Changes
    module V14
      class AddGcseCompletingQualificationData < VersionChange
        description 'Add GCSE completing qualification data'

        resource ApplicationPresenter, [ApplicationPresenter::AddGcseCompletingQualificationData]
      end
    end
  end
end

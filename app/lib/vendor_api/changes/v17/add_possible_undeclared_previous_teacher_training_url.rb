module VendorAPI
  module Changes
    module V17
      class AddPossibleUndeclaredPreviousTeacherTrainingUrl < VersionChange
        description 'Add possible undeclared previous teacher training details URL'

        resource ApplicationPresenter, [ApplicationPresenter::AddPossibleUndeclaredPreviousTeacherTrainingUrl]
      end
    end
  end
end

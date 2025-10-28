module VendorAPI
  module Changes
    module V17
      class AddPreviousTeacherTrainingToApplication < VersionChange
        description 'Add previous_teacher_training to the Application object'

        resource ApplicationPresenter, [ApplicationPresenter::AddPreviousTeacherTrainingToApplication]
      end
    end
  end
end

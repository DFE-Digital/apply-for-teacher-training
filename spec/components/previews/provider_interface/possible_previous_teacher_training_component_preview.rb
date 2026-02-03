module ProviderInterface
  class PossiblePreviousTeacherTrainingComponentPreview < ViewComponent::Preview
    layout 'previews/provider'
    def one_possible_previous_teacher_trainings
      render PossiblePreviousTeacherTrainingComponent.new(
        possible_previous_teacher_trainings: FactoryBot.build_list(
          :possible_previous_teacher_training, 1
        ),
      )
    end

    def many_possible_previous_teacher_trainings
      render PossiblePreviousTeacherTrainingComponent.new(
        possible_previous_teacher_trainings: FactoryBot.build_list(
          :possible_previous_teacher_training, 3
        ),
      )
    end
  end
end

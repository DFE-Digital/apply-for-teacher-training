module ProviderInterface
  class PossiblePreviousTeacherTrainingComponent < ViewComponent::Base
    attr_reader :possible_previous_teacher_trainings
    def initialize(possible_previous_teacher_trainings:)
      @possible_previous_teacher_trainings = possible_previous_teacher_trainings
    end
  end
end

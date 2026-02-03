module ProviderInterface
  class PossiblePreviousTeacherTrainingComponent < ViewComponent::Base
    attr_reader :possible_previous_teacher_trainings
    def initialize(possible_previous_teacher_trainings:)
      @possible_previous_teacher_trainings = possible_previous_teacher_trainings
    end

    def render?
      @possible_previous_teacher_trainings.any?
    end
  end
end

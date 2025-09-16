class PreviousTeacherTrainingComponent < ViewComponent::Base
  attr_reader :previous_teacher_training

  def initialize(previous_teacher_training)
    @previous_teacher_training = previous_teacher_training
  end

  def render?
    @previous_teacher_training.present?
  end
end

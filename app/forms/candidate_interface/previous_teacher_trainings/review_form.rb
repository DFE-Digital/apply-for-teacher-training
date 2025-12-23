module CandidateInterface
  module PreviousTeacherTrainings
    class ReviewForm
      include ActiveModel::Model

      attr_accessor :completed, :previous_teacher_training, :application_form

      validates :completed, presence: true
      validates :completed, inclusion: { in: %w[true false] }

      delegate :previous_teacher_training_completed, to: :application_form

      def initialize(application_form)
        @application_form = application_form
        @completed = previous_teacher_training_completed
      end

      def save
        return if invalid?

        application_form.update(
          previous_teacher_training_completed: ActiveModel::Type::Boolean.new.cast(completed),
        )
      end
    end
  end
end

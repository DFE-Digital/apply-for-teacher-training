module CandidateInterface
  module PreviousTeacherTrainings
    class DetailsForm
      include ActiveModel::Model

      attr_accessor :details, :previous_teacher_training

      validates :details, presence: true, word_count: { maximum: 200 }

      def initialize(previous_teacher_training)
        @previous_teacher_training = previous_teacher_training
        @details = previous_teacher_training.details
      end

      def save
        return if invalid?

        previous_teacher_training.details = details
        previous_teacher_training.save!
      end
    end
  end
end

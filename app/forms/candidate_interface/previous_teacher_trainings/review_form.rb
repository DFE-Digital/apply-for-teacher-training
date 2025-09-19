module CandidateInterface
  module PreviousTeacherTrainings
    class ReviewForm
      include ActiveModel::Model

      attr_accessor :completed, :previous_teacher_training, :application_form

      validates :completed, presence: true
      validates :completed, inclusion: { in: %w[true false] }

      delegate :previous_teacher_training_completed, to: :application_form
      delegate :draft?, :published?, :started_yes?, :started, :provider_name, :started_at,
               :ended_at, :details, :id,
               to: :previous_teacher_training

      def initialize(previous_teacher_training)
        @previous_teacher_training = previous_teacher_training
        @application_form = previous_teacher_training.application_form
        @completed = previous_teacher_training_completed
      end

      def save
        return if invalid?

        old_trainings = application_form.previous_teacher_trainings.where(
          status: 'published',
        ).where.not(id:)

        ActiveRecord::Base.transaction do
          old_trainings&.destroy_all
          previous_teacher_training.published!
          application_form.update(
            previous_teacher_training_completed: ActiveModel::Type::Boolean.new.cast(completed),
          )
        end

        true
      end
    end
  end
end

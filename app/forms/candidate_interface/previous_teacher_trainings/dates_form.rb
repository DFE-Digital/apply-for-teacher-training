module CandidateInterface
  module PreviousTeacherTrainings
    class DatesForm
      include ActiveModel::Model
      include DateValidationHelper

      attr_accessor :start_date_day, :start_date_month, :start_date_year,
                    :end_date_day, :end_date_month, :end_date_year,
                    :previous_teacher_training

      validates :started_at, date: { month_and_year: true, presence: true, future: true, before: :ended_at }
      validates :ended_at, date: { month_and_year: true, presence: true, future: true }

      def initialize(previous_teacher_training)
        @previous_teacher_training = previous_teacher_training
        @start_date_month = previous_teacher_training.started_at&.month
        @start_date_year = previous_teacher_training.started_at&.year
        @end_date_month = previous_teacher_training.ended_at&.month
        @end_date_year = previous_teacher_training.ended_at&.year
      end

      def save
        return if invalid?

        previous_teacher_training.assign_attributes(started_at:, ended_at:)
        previous_teacher_training.save!
      end

      def started_at
        valid_or_invalid_date(start_date_year, start_date_month)
      end

      def ended_at
        valid_or_invalid_date(end_date_year, end_date_month)
      end
    end
  end
end

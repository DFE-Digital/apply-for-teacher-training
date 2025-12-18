module CandidateInterface
  module PreviousTeacherTrainings
    class StartForm
      include ActiveModel::Model
      include Rails.application.routes.url_helpers

      Started = Data.define(:value, :name)
      attr_accessor :previous_teacher_training, :started

      validates :started, presence: true

      def initialize(previous_teacher_training = nil)
        @previous_teacher_training = previous_teacher_training
        @started = previous_teacher_training&.started
      end

      def options
        ::PreviousTeacherTraining.starteds.map do |_, value|
          Started.new(value: value, name: value.capitalize)
        end
      end

      def save
        return if invalid?

        if started == PreviousTeacherTraining.starteds[:no]
          previous_teacher_training.assign_attributes(
            # Add new columns here
            provider_name: nil,
            started_at: nil,
            ended_at: nil,
            details: nil,
          )
        end

        previous_teacher_training.started = started
        previous_teacher_training.save!
      end

      def back_path(params)
        if params[:return_to] == 'review' && previous_teacher_training.reviewable?
          publish_candidate_interface_previous_teacher_training_path(previous_teacher_training)
        end
      end

      def next_path(params)
        if previous_teacher_training.started_yes?
          back_path(params) || new_candidate_interface_previous_teacher_training_name_path(previous_teacher_training)
        elsif previous_teacher_training.started_no?
          publish_candidate_interface_previous_teacher_training_path(previous_teacher_training)
        end
      end
    end
  end
end

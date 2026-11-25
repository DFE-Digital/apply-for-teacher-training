module SupportInterface
  module ApplicationForms
    module PreviousTeacherTrainings
      class RemoveForm
        include ActiveModel::Model
        include Rails.application.routes.url_helpers

        attr_accessor :previous_teacher_training

        def initialize(previous_teacher_training)
          @previous_teacher_training = previous_teacher_training
        end

        def destroy
          if application_form.previous_teacher_trainings.published.count > 1
            previous_teacher_training.destroy
          else
            previous_teacher_training.started = 'no'
            previous_teacher_training.provider_name = nil
            previous_teacher_training.provider_id = nil
            previous_teacher_training.started_at = nil
            previous_teacher_training.ended_at = nil
            previous_teacher_training.details = nil
            previous_teacher_training.save!
          end
        end

      private

        def application_form
          @application_form ||= previous_teacher_training.application_form
        end
      end
    end
  end
end

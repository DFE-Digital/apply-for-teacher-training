module SupportInterface
  module ApplicationForms
    module PreviousTeacherTrainings
      class DeclarationForm
        include ActiveModel::Model
        include Rails.application.routes.url_helpers

        Started = Data.define(:value, :name)
        attr_accessor :previous_teacher_training, :started, :audit_comment

        validates :started, presence: true
        validates :audit_comment, presence: true

        def initialize(previous_teacher_training)
          @previous_teacher_training = previous_teacher_training
          @started = previous_teacher_training.started
        end

        def options
          ::PreviousTeacherTraining.starteds.map do |_, value|
            Started.new(value: value, name: value.capitalize)
          end
        end

        def save
          return false unless valid?

          previous_teacher_training.started = started

          if previous_teacher_training.started_no?
            previous_teacher_training.started = started
            previous_teacher_training.audit_comment = audit_comment
            previous_teacher_training.provider_name = nil
            previous_teacher_training.provider_id = nil
            previous_teacher_training.started_at = nil
            previous_teacher_training.ended_at = nil
            previous_teacher_training.details = nil
            previous_teacher_training.save!
          end

          previous_teacher_training.make_published unless previous_teacher_training.started_yes?

          true
        end

        def next_path
          if previous_teacher_training.started_yes? && application_form.previous_teacher_trainings.count > 1
            support_interface_application_form_edit_teacher_training_previous_teacher_trainings_path(application_form, previous_teacher_training)
          elsif previous_teacher_training.started_no?
            support_interface_application_form_path(application_form)
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

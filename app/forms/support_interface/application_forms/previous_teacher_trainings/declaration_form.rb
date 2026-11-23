module SupportInterface
  module ApplicationForms
    module PreviousTeacherTrainings
      class DeclarationForm < BaseForm
        attr_accessor :started, :audit_comment

        validates :started, inclusion: { in: %w[yes no] }
        validates :audit_comment, presence: true

        def initialize(previous_teacher_training)
          @previous_teacher_training = previous_teacher_training
          @started = previous_teacher_training.previous_teacher_trainings_started
        end

        def save
          return false unless valid?

          @application_form.previous_teacher_trainings_started = started
          @application_form.audit_comment = audit_comment
          @application_form.save!
        end
      end
    end
  end
end

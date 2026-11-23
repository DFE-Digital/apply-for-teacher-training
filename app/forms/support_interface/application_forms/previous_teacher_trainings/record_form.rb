module Forms
  module SupportInterface
    module ApplicationForms
      module PreviousTeacherTrainings
        class RecordForm < BaseForm
          attr_accessor :started, :audit_comment

          validates :provider_name, presence: true
          validates :audit_comment, presence: true

          def initialize(application_form)
            @application_form = application_form
            @started = application_form.previous_teacher_trainings_started
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
end

module SupportInterface
  module ApplicationForms
    class EditBecomingATeacherForm
      include ActiveModel::Model

      attr_accessor :becoming_a_teacher, :audit_comment

      validates :becoming_a_teacher,
                word_count: { maximum: 600 },
                presence: true

      validates :audit_comment, presence: true

      def self.build_from_application(application_form)
        new(
          becoming_a_teacher: application_form.becoming_a_teacher,
        )
      end

      def save(application_form)
        return false unless valid?

        ApplicationForm.transaction do
          if update_application_form(application_form) && update_application_choices(application_form)
            true
          else
            errors.add(:save_error, 'The record could not be saved. Please try again.')
            raise ActiveRecord::Rollback # returns nil
          end
        end
      end

    private

      def update_application_form(application_form)
        application_form.update(
          becoming_a_teacher:,
          audit_comment:,
        )
      end

      def update_application_choices(application_form)
        application_form
          .application_choices
          .all? { |ac| ac.update(personal_statement: becoming_a_teacher) }
      end
    end
  end
end

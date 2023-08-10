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

        if application_form.continuous_applications?
          application_form.update!(
            becoming_a_teacher:,
            audit_comment:,
          )
        else
          ApplicationForm.transaction do
            application_form.update!(
              becoming_a_teacher:,
              audit_comment:,
            )
            application_form
              .application_choices
              .all? { |ac| ac.update!(personal_statement: becoming_a_teacher) }
          end
        end
      end
    end
  end
end

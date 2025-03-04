module SupportInterface
  module ApplicationForms
    class EditBecomingATeacherForm
      include ActiveModel::Model

      attr_accessor :becoming_a_teacher, :audit_comment, :application_form

      validates :becoming_a_teacher,
                word_count: { maximum: 1000 },
                presence: true

      validates :audit_comment, presence: true
      validates_with SafeChoiceUpdateValidator

      def self.build_from_application(application_form)
        new(
          becoming_a_teacher: application_form.becoming_a_teacher,
        )
      end

      def save(application_form)
        @application_form = application_form
        return false unless valid?

        application_form.update!(
          becoming_a_teacher:,
          audit_comment:,
        )
      end
    end
  end
end

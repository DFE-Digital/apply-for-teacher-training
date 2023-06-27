module SupportInterface
  module ApplicationForms
    class UpdateOfferedCourseOptionForm
      include ActiveModel::Model

      attr_accessor :course_option_id, :audit_comment, :accept_guidance, :confirm_course_change, :checkbox_rendered

      validates :course_option_id, :audit_comment, :accept_guidance, presence: true
      validates :confirm_course_change, presence: true, if: :checkbox_rendered?
      validates_with ZendeskUrlValidator

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        check_course_full!

        application_choice.update_course_option_and_associated_fields!(course_option, audit_comment:)
        application_choice.offer.ske_conditions.destroy_all
      end

      def course_option
        @_course_option ||= CourseOption.find(course_option_id)
      end

    private

      def check_course_full!
        return if confirm_course_change.present?
        return if course_option.vacancy_status == 'vacancies'

        raise CourseFullError, I18n.t('support_interface.errors.messages.course_full_error')
      end

      def checkbox_rendered?
        checkbox_rendered == 'true'
      end
    end
  end
end

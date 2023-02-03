module SupportInterface
  module ApplicationForms
    class ChangeCourseChoiceForm
      include ActiveModel::Model

      attr_accessor :course_option, :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, :confirm_course_change, :checkbox_rendered

      validates :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, presence: true
      validates :confirm_course_change, presence: true, if: :checkbox_rendered?
      validates_with ZendeskUrlValidator

      # Allow ChangeOfferedCourseController to use
      # this form as well as CoursesController.
      def initialize(attrs = {})
        if (course_option_id = attrs.delete(:course_option_id))
          self.course_option = CourseOption.find(course_option_id)
          self.provider_code = course_option.course.provider.code
          self.course_code = course_option.course.code
          self.study_mode = course_option.study_mode
          self.site_code = course_option.site.code
          self.audit_comment_ticket = attrs.delete(:audit_comment)
        end

        super(attrs)
      end

      def save(application_choice_id)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        SupportInterface::ChangeApplicationChoiceCourseOption.new(
          application_choice_id:,
          provider_id:,
          course_code:,
          study_mode:,
          site_code:,
          audit_comment: audit_comment_ticket,
          confirm_course_change:,
        ).call
      rescue ActiveRecord::RecordNotFound
        raise CourseChoiceError, 'This is not a valid course option'
      rescue ActiveRecord::RecordInvalid
        raise CourseChoiceError, 'This course option has already been taken'
      end

      def provider_id
        provider = Provider.find_by(code: provider_code)

        raise CourseChoiceError, 'This is not a valid provider code' if provider.nil?

        provider.id
      end

      def checkbox_rendered?
        checkbox_rendered == 'true'
      end
    end
  end
end

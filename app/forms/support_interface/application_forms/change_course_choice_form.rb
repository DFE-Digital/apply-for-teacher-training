module SupportInterface
  module ApplicationForms
    class ChangeCourseChoiceForm
      include ActiveModel::Model

      attr_accessor :application_choice_id, :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, :confirm_course_change, :checkbox_rendered

      validates :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, presence: true
      validates :confirm_course_change, presence: true, if: :checkbox_rendered?
      validates_with ZendeskUrlValidator

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        SupportInterface::ChangeApplicationChoiceCourseOption.new(
          application_choice_id: application_choice,
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

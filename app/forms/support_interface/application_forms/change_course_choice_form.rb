module SupportInterface
  module ApplicationForms
    class ChangeCourseChoiceForm
      include ActiveModel::Model

      attr_accessor :application_choice_id, :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket

      validates :provider_code, :course_code, :study_mode, :site_code, :accept_guidance, :audit_comment_ticket, presence: true
      validates :audit_comment_ticket, format: { with: /\A((http|https):\/\/)?(www.)?becomingateacher.zendesk.com\/agent\/tickets\// }

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        SupportInterface::ChangeApplicationChoiceCourseOption.new(
          application_choice_id: application_choice,
          provider_id: Provider.find_by(code: provider_code).id,
          course_code: course_code,
          study_mode: study_mode,
          site_code: site_code,
          audit_comment: audit_comment_ticket,
        ).call
      end
    end
  end
end

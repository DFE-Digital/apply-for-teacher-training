class SendNewApplicationEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.awaiting_provider_decision?

    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_submitted(provider_user, application_choice).deliver_now

      course_name = application_choice.course.name
      course_code = application_choice.course.code
      audit_comment = I18n.t('submit_application_success.audit_comment', course_name: course_name, course_code: course_code, provider_user_email: provider_user.email_address)
      application_comment = SupportInterface::ApplicationCommentForm.new(comment: audit_comment)
      application_comment.save(application_choice.application_form)
    end
  end
end

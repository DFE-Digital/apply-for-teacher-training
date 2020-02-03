class SendRejectByDefaultEmailToProvider
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    return false unless application_choice.rejected?

    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.application_rejected_by_default(provider_user, application_choice).deliver_now

      course_name_and_code = application_choice.course.name_and_code
      audit_comment =
        'Rejected by default email have been sent to the provider user' +
        " #{provider_user.email_address} for application #{course_name_and_code}."
      application_choice.application_form.update!(audit_comment: audit_comment)
    end
  end
end

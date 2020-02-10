class SendChaseEmailToProvider
  def self.call(application_choice:)
    application_choice.provider.provider_users.each do |provider_user|
      ProviderMailer.chase_provider_decision(provider_user, application_choice).deliver
      audit_chase_email(provider_user, application_choice)
    end
    ChaserSent.create!(chased: application_choice, chaser_type: :provider_decision_request)
  end

  def self.audit_chase_email(provider_user, application_choice)
    course_name_and_code = application_choice.course.name_and_code
    audit_comment =
      "Chase emails have been sent to the provider #{provider_user.email_address} because " +
      "the application for #{course_name_and_code} is close to its RBD date."
    application_choice.application_form.update!(audit_comment: audit_comment)
  end
end

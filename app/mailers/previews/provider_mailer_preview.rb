class ProviderMailerPreview < ActionMailer::Preview
  def account_created_email
    ProviderMailer.account_created(provider_user)
  end

  def application_submitted
    ProviderMailer.application_submitted(provider_user, application_choice)
  end

  def application_rejected_by_default
    ProviderMailer.application_rejected_by_default(provider_user, application_choice)
  end

  def chase_provider_decision_after_twenty_working_days
    ProviderMailer.chase_provider_decision(provider_user, application_choice)
  end

private

  def application_choice
    course_option = FactoryBot.create(:course_option, course: FactoryBot.build(:course))
    FactoryBot.create(:submitted_application_choice, course_option: course_option)
  end

  def provider_user
    FactoryBot.build :provider_user
  end
end

class Provider::ReportMailerPreview < ActionMailer::Preview
  def recruitment_performance_report_reminder
    provider_user = FactoryBot.build_stubbed(:provider_user)
    ProviderMailer.recruitment_performance_report_reminder(provider_user)
  end
end

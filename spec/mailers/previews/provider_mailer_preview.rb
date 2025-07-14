class ProviderMailerPreview < ActionMailer::Preview
  def reference_received
    reference = FactoryBot.create(:reference, :feedback_provided)
    course = FactoryBot.build_stubbed(:course, provider:)
    ProviderMailer.reference_received(reference:, application_choice:, provider_user:, course:)
  end




















  def apply_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.apply_service_is_now_open(provider_user)
  end

  def find_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.find_service_is_now_open(provider_user)
  end



  def respond_to_applications_before_reject_by_default_date
    provider_user = FactoryBot.build(:provider_user)
    ProviderMailer.respond_to_applications_before_reject_by_default_date(provider_user)
  end

private

  def provider
    @provider ||= FactoryBot.create(:provider)
  end

  def site
    @site ||= FactoryBot.create(:site, code: '-', name: 'Main site', provider:)
  end

  def application_choice
    course = FactoryBot.create(:course, provider:)
    course_option = FactoryBot.create(:course_option, course:, site:)
    FactoryBot.create(:application_choice, :awaiting_provider_decision, :with_completed_application_form, course_option:, course:)
  end

  def provider_user
    FactoryBot.build(:provider_user)
  end
end

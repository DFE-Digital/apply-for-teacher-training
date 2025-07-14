class Provider::DeadlinesMailerPreview < ActionMailer::Preview
  def find_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.find_service_is_now_open(provider_user)
  end


  def apply_service_is_now_open
    provider_user = FactoryBot.create(:provider_user)
    ProviderMailer.apply_service_is_now_open(provider_user)
  end

  def respond_to_applications_before_reject_by_default_date
    provider_user = FactoryBot.build(:provider_user)
    ProviderMailer.respond_to_applications_before_reject_by_default_date(provider_user)
  end
end

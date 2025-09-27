class CandidateInterface::ProviderContactInformationComponent < ViewComponent::Base
  def initialize(provider:)
    @provider = provider
  end

  attr_reader :provider

  def show_email_and_phone?
    provider.email_address.present? && provider.phone_number.present?
  end

  def show_only_phone?
    provider.email_address.blank? && provider.phone_number.present?
  end

  def show_only_email?
    provider.email_address.present? && provider.phone_number.blank?
  end

  def render?
    provider.email_address.present? || provider.phone_number.present?
  end
end

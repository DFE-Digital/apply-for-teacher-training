class ServiceInformationBanner < ViewComponent::Base
  def initialize(namespace:)
    @namespace = namespace
  end

  def header_content
    HostingEnvironment.sandbox_mode? ? t("service_information_banner.#{@namespace}.sandbox_header") : t("service_information_banner.#{@namespace}.header")
  end

  def body_content
    HostingEnvironment.sandbox_mode? ? t("service_information_banner.#{@namespace}.sandbox_body") : t("service_information_banner.#{@namespace}.body_html", contact_us_link:, email_link:)
  end

  def render?
    FeatureFlag.active?('service_information_banner')
  end

private

  def contact_us_link
    view_context.govuk_link_to('contact us', 'https://getintoteaching.education.gov.uk/help-and-support', target: '_blank')
  end

  def email_link
    view_context.mail_to('becomingateacher@digital.education.gov.uk')
  end
end

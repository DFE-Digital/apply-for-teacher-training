class ServiceInformationBanner < ViewComponent::Base
  def initialize(namespace:)
    @namespace = namespace
  end

  def header_content
    HostingEnvironment.sandbox_mode? ? t("service_information_banner.#{@namespace}.sandbox_header") : t("service_information_banner.#{@namespace}.header")
  end

  def body_content
    HostingEnvironment.sandbox_mode? ? t("service_information_banner.#{@namespace}.sandbox_body") : t("service_information_banner.#{@namespace}.body")
  end

  def render?
    FeatureFlag.active?('service_information_banner')
  end
end

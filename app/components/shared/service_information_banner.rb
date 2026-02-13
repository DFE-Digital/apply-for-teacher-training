class ServiceInformationBanner < ViewComponent::Base
  def initialize(interface:, preview: false)
    @interface = interface.to_s.downcase
    @preview = preview
  end

  def header_content
    banner.header
  end

  def body_content
    banner.body
  end

  def render?
    @preview ||
      (banner.present? &&
        FeatureFlag.active?('service_information_banner'))
  end

private

  def banner
    @banner ||= find_banner
  end

  def find_banner
    scope = ServiceBanner.where(interface: @interface).order(created_at: :desc)
    @preview ? scope.first : scope.published.first
  end
end

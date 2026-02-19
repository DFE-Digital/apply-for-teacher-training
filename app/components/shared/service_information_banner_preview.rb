class ServiceInformationBannerPreview < ViewComponent::Base
  def initialize(banner_id:)
    @banner_id = banner_id
  end

  def header_content
    banner.header
  end

  def body_content
    banner.body
  end

  def render?
    banner.present?
  end

private

  def banner
    ServiceBanner.find(@banner_id)
  end
end

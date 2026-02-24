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

private

  def banner
    @banner ||= ServiceBanner.find(@banner_id)
  end
end

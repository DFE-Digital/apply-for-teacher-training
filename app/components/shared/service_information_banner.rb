class ServiceInformationBanner < ViewComponent::Base
  def initialize(interface:)
    @interface = interface
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
    @banner ||= ServiceBanner.published.where(interface: @interface).order(created_at: :desc).first
  end
end

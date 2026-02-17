class ServiceInformationBanner < ViewComponent::Base
  def initialize(interface: nil, banner_id: nil, preview: false)
    @interface = interface.to_s.downcase.tr('_', ' ')
    @preview = preview
    @banner_id = banner_id
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
        banner.published?)
  end

private

  def banner
    @banner ||= find_banner
  end

  def find_banner
    return ServiceBanner.find(@banner_id) if @banner_id.present?

    scope = ServiceBanner.where(interface: @interface).order(created_at: :desc)
    @preview ? scope.draft.first : scope.published.first
  end
end

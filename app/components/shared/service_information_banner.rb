class ServiceInformationBanner < ViewComponent::Base
  def initialize(interface:, preview: false)
    @interface = interface.to_s.downcase.tr('_', ' ')
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
        banner.published?)
  end

private

  def banner
    @banner ||= find_banner
  end

  def find_banner
    scope = ServiceBanner.where(interface: @interface).order(created_at: :desc)
    @preview ? scope.draft.first : scope.published.first
  end
end

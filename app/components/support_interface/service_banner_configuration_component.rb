module SupportInterface
  class ServiceBannerConfigurationComponent < ViewComponent::Base
    attr_reader :interface

    def initialize(interface:)
      @interface = interface
    end

    def rows
      [
        show_service_banner_row,
        banner_content_row,
        history_row,
      ].compact
    end

  private

    def show_service_banner_row
      {
        key: 'Show service banner',
        value: live_banner ? 'Yes' : 'No',
        action: {
          href: support_interface_edit_show_service_banner_path(interface: @interface),
          visually_hidden_text: 'Change',
        },
      }
    end

    def banner_content_row
      return unless live_banner

      {
        key: 'Banner content',
        value: t('.live_banner_html', header: live_banner.header, body: live_banner.body),
        action: {
          href: support_interface_edit_configure_service_banner_path(live_banner, interface: @interface),
          visually_hidden_text: 'Change',
        },
      }
    end

    def history_row
      {
        key: 'History',
        value: audit_text,
      }
    end

    def audit_text
      return '-' unless ServiceBanner.where(interface: @interface.downcase.tr('_', ' ')).any?

      render SupportInterface::ServiceBannerAuditTrailComponent.new(interface: @interface)
    end

    def live_banner
      ServiceBanner.where(interface: @interface.downcase.tr('_', ' '), status: 'published').order(created_at: :desc).first
    end
  end
end

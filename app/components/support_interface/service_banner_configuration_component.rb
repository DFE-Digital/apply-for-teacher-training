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
      ]
    end

  private

    def show_service_banner_row
      {
        key: 'Show service banner',
        value: @show_service_banner ? 'Yes' : 'No',
        action: {
          href: support_interface_edit_show_service_banner_path(interface: @interface),
          visually_hidden_text: 'Change',
        },
      }
    end

    def banner_content_row
      {
        key: 'Banner content',
        value: '-',
      }
    end

    def history_row
      {
        key: 'History',
        value: '-',
      }
    end
  end
end

module SupportInterface
  class ServiceBannerConfigurationComponent < ViewComponent::Base
    attr_reader :interface, :show_service_banner

    def initialize(interface:, show_service_banner: false)
      @interface = interface
      @show_service_banner = show_service_banner
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

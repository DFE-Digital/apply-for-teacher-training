module ProviderInterface
  class InformationBannerComponent < ViewComponent::Base
    def initialize; end

    def header_content
      HostingEnvironment.sandbox_mode? ? t('notification_banner.sandbox_header') : t('notification_banner.header')
    end

    def body_content
      HostingEnvironment.sandbox_mode? ? t('notification_banner.sandbox_body') : t('notification_banner.body')
    end

    def render?
      FeatureFlag.active?('provider_information_banner')
    end
  end
end

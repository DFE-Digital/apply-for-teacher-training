module SupportInterface
  class ProviderSyncCoursesToggleComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(provider:)
      @provider = provider
    end

    def toggle_path
      support_interface_enable_provider_course_syncing_path(provider)
    end

    def button_label
      t('provider_sync_courses.button_label.enable')
    end

    def status_label
      provider.sync_courses? ? t('provider_sync_courses.status_label.enabled') : t('provider_sync_courses.status_label.disabled')
    end

  private

    attr_reader :provider
  end
end

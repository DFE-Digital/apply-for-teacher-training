module SupportInterface
  class ProviderSyncCoursesToggleComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(provider:)
      @provider = provider
    end

    def toggle_path
      if provider.sync_courses?
        support_interface_disable_provider_course_syncing_path(provider)
      else
        support_interface_enable_provider_course_syncing_path(provider)
      end
    end

    def button_label
      provider.sync_courses? ? 'Disable course syncing from Find' : 'Enable course syncing from Find'
    end

    def status_label
      "Course synching for this provider is switched #{provider.sync_courses? ? 'on' : 'off'}."
    end

  private

    attr_reader :provider
  end
end

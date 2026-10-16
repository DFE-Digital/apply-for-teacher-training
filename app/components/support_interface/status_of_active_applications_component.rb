module SupportInterface
  class StatusOfActiveApplicationsComponent < ApplicationComponent
    attr_reader :provider_report, :provider, :active_application_status_data, :view

    def initialize(provider_report:, provider:, active_application_status_data:, view: nil)
      @provider_report = provider_report
      @provider = provider
      @active_application_status_data = active_application_status_data
      @view = view
    end
  end
end

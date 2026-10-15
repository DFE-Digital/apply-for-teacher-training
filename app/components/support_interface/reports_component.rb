module SupportInterface
  class ReportsComponent < ApplicationComponent
    include ViewHelper

    attr_accessor :provider, :current_timetable, :previous_timetable, :view

    def initialize(provider:, current_timetable:, previous_timetable:, view:)
      @provider = provider
      @current_timetable = current_timetable
      @previous_timetable = previous_timetable
      @view = view
    end

    def active_application_link
      if view == 'reports'
        support_interface_reports_status_of_active_applications_path(
          provider_id: provider.id,
        )
      else
        support_interface_status_of_active_applications_path(
          provider,
        )
      end
    end

    def withdrawal_report_link
      if view == 'reports'
        support_interface_reports_withdrawal_reasons_report_path(
          provider_id: provider.id,
        )
      else
        support_interface_withdrawal_reasons_report_path(
          provider,
        )
      end
    end

    def recruitment_performance_link
      if view == 'reports'
        support_interface_reports_provider_recruitment_report_path(
          provider_id: provider.id,
          recruitment_cycle_year: previous_timetable.recruitment_cycle_year,
        )
      else
        support_interface_provider_recruitment_report_path(
          provider,
          recruitment_cycle_year: previous_timetable.recruitment_cycle_year,
        )
      end
    end
  end
end

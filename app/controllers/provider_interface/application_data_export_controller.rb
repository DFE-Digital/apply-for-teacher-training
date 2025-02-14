module ProviderInterface
  class ApplicationDataExportController < ProviderInterfaceController
    include ActionController::Live
    include CSVNameHelper
    include StreamableDataExport

    def new
      @application_data_export_form = ApplicationDataExportForm.new(current_provider_user:)
    end

    def export
      @application_data_export_form = ApplicationDataExportForm.new(application_data_export_params.merge({ current_provider_user: }))

      if @application_data_export_form.valid?
        providers = @application_data_export_form.selected_providers
        cycle_years = @application_data_export_form.selected_years
        status = @application_data_export_form.selected_statuses

        data = GetApplicationChoicesForProviders
          .call(
            providers:,
            includes: [
              :provider,
              :accredited_provider,
              :site,
              :current_site,
              :current_provider,
              :current_accredited_provider,
              course: %i[provider accredited_provider],
              course_option: %i[course site],
              current_course: %i[provider accredited_provider],
              current_course_option: %i[course site],
              application_form: %i[candidate english_proficiency application_qualifications],
            ],
            recruitment_cycle_year: RecruitmentCycleTimetable.pluck(:recruitment_cycle_year),
          )

        application_choices = FilterApplicationChoicesForProviders.call(
          application_choices: data,
          filters: {
            status:,
            recruitment_cycle_year: cycle_years,
            hide_in_reporting: false,
          },
        )

        filename = csv_filename(export_name: 'application-data', cycle_years:, providers:)

        stream_csv(data: application_choices, filename:) do |row|
          ApplicationDataExport.export_row(row)
        end
      else
        render :new
      end
    end

  private

    def application_data_export_params
      params.require(:provider_interface_application_data_export_form).permit(:application_status_choice, statuses: [], provider_ids: [], recruitment_cycle_years: [])
    end
  end
end

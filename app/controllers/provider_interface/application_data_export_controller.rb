module ProviderInterface
  class ApplicationDataExportController < ProviderInterfaceController
    include StreamableDataExport
    include CSVNameHelper

    BATCH_SIZE = 300

    before_action :redirect_to_hesa_export_unless_feature_enabled

    def new
      @application_data_export_form = ApplicationDataExportForm.new(current_provider_user: current_provider_user)
    end

    def export
      @application_data_export_form = ApplicationDataExportForm.new(application_data_export_params.merge({ current_provider_user: current_provider_user }))

      if @application_data_export_form.valid?
        providers = @application_data_export_form.selected_providers
        cycle_years = @application_data_export_form.selected_years
        statuses = @application_data_export_form.selected_statuses

        export_data = GetApplicationChoicesForProviders
          .call(
            providers: providers,
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
          )
          .where('courses.recruitment_cycle_year' => cycle_years)
          .where(status: statuses)
          .where('candidates.hide_in_reporting': false)
          .find_each(batch_size: BATCH_SIZE)

        self.response_body = streamable_response(
          filename: csv_filename(export_name: 'application-data', cycle_years: cycle_years, providers: providers),
          export_headings: ApplicationDataExport.export_row(export_data.first).keys,
          export_data: export_data,
          item_yielder: proc { |item| ApplicationDataExport.export_row(item).values },
        )
      else
        render :new
      end
    end

  private

    def application_data_export_params
      params.require(:provider_interface_application_data_export_form).permit(:application_status_choice, statuses: [], provider_ids: [], recruitment_cycle_years: [])
    end

    def redirect_to_hesa_export_unless_feature_enabled
      redirect_to provider_interface_new_hesa_export_path unless FeatureFlag.active?(:export_application_data)
    end
  end
end

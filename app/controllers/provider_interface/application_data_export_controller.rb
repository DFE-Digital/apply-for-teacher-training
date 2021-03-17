module ProviderInterface
  class ApplicationDataExportController < ProviderInterfaceController
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

        application_choices = GetApplicationChoicesForProviders
          .call(
            providers: providers,
            includes: [
              :provider,
              :accredited_provider,
              :site,
              course: %i[provider accredited_provider],
              course_option: %i[course site],
              offered_course_option: %i[course site],
              application_form: %i[candidate english_proficiency],
            ],
          )
          .where('courses.recruitment_cycle_year' => cycle_years)
          .where('status IN (?)', statuses)
          .where('candidates.hide_in_reporting': false)

        csv_data = ApplicationDataExport.call(application_choices: application_choices)
        send_data csv_data, filename: csv_filename
      else
        render :new
      end
    end

  private

    def application_data_export_params
      params.require(:provider_interface_application_data_export_form).permit(:application_status_choice, statuses: [], provider_ids: [], recruitment_cycle_years: [])
    end

    def csv_filename
      "#{Time.zone.now}.applications-export.csv"
    end

    def redirect_to_hesa_export_unless_feature_enabled
      redirect_to provider_interface_new_hesa_export_path unless FeatureFlag.active?(:export_application_data)
    end
  end
end

module ProviderInterface
  class ApplicationDataExportController < ProviderInterfaceController
    before_action :redirect_to_hesa_export_unless_feature_enabled

    def new
      @application_data_export_form = ApplicationDataExportForm.new(current_provider_user: current_provider_user)
    end

    def export
      @application_data_export_form = ApplicationDataExportForm.new(application_data_export_params.merge({ current_provider_user: current_provider_user }))

      if @application_data_export_form.valid?
        render :new
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
      render_404 unless FeatureFlag.active?(:export_application_data)
    end
  end
end

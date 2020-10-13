module ProviderInterface
  class ApplicationsExportsController < ProviderInterfaceController
    def new
      @available_providers = current_provider_user.providers
      @form = ApplicationsExportForm.new(export_params)
    end

    def export
      @available_providers = current_provider_user.providers
      @form = ApplicationsExportForm.new(export_params)

      render(:new, formats: :html) and return unless @form.valid?

      respond_to do |format|
        format.csv do
          send_data HesaDataExport.new(export_options: export_params).call, disposition: 'attachment', filename: csv_filename
        end
      end
    end

  private

    def csv_filename
      "#{Time.zone.now}.applications-export.csv"
    end

    def export_params
      return {} unless params.key?(:provider_interface_applications_export_form)

      params.require(:provider_interface_applications_export_form)
        .permit(:filter_by_status, :include_diversity_information, provider_ids: [], recruitment_cycle_years: [], statuses: [])
    end
  end
end

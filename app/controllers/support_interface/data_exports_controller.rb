module SupportInterface
  class DataExportsController < SupportInterfaceController
    def new; end

    def index
      @data_exports = DataExport.includes(:initiator).order(id: :desc).page(params[:page] || 1).per(30)
    end

    def create
      export_type = DataExport::EXPORT_TYPES.fetch(params.fetch(:export_type_id).to_sym)
      data_export = DataExport.create!(name: export_type.fetch(:name), initiator: current_support_user)
      DataExporter.perform_async(export_type.fetch(:class), data_export.id)

      redirect_to support_interface_data_export_path(data_export)
    end

    def show
      @data_export = DataExport.find(params[:id])
    end

    def download
      data_export = DataExport.find(params[:id])
      send_data data_export.data, filename: data_export.filename, disposition: :attachment
    end
  end
end

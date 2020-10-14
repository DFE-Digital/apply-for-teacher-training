module SupportInterface
  class DataExportsController < SupportInterfaceController
    def show
      @data_export = DataExport.find(params[:id])
    end

    def download
      data_export = DataExport.find(params[:id])
      send_data data_export.data, filename: data_export.filename, disposition: :attachment
    end
  end
end

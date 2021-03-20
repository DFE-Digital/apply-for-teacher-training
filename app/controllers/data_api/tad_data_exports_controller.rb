module DataAPI
  class TADDataExportsController < ActionController::API
    include ServiceAPIUserAuthentication

    def index
      exports = DataAPI::TADExport.all

      formatted_exports = exports.map do |export|
        {
          export_date: export.completed_at,
          description: export.name,
          url: data_api_tad_export_url(export.id),
        }
      end

      render json: { data: formatted_exports.as_json }
    end

    def show
      data_export = DataAPI::TADExport.all.find(params[:id])
      serve_export(data_export)
    end

    def latest
      data_export = DataAPI::TADExport.latest
      serve_export(data_export)
    end

  private

    def serve_export(export)
      export.update!(audit_comment: "File downloaded via API using token ID #{@authenticating_token.id}")
      send_data export.data, filename: export.filename
    end
  end
end

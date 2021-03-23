module DataAPI
  class TADDataExportsController < ActionController::API
    include ServiceAPIUserAuthentication

    def latest
      data_export = DataAPI::TADExport.latest
      data_export.update!(audit_comment: "File downloaded via API using token ID #{@authenticating_token.id}")
      send_data data_export.data, filename: data_export.filename
    end
  end
end

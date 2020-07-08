require 'csv'

module UCASMatching
  class UploadMatchingData
    include Sidekiq::Worker

    # The `dfe_apply_itt_applications` folder in Movit. This will probably
    # change for the production version.
    UPLOAD_FOLDER = 685520099

    def perform
      unless ENV['UCAS_USERNAME']
        Rails.logger.info 'UCAS credentials aren\'t configured, assuming that this this is a test environment. Not uploading data.'
        return
      end

      filename = "/tmp/dfe_apply_itt_applications_#{DateTime.now}.csv"

      File.open(filename, 'w') do |f|
        f.write(csv_as_string)
      end

      # https://transfer.ucasenvironments.com/swagger/ui/index#/Folders/POSTapi%2Fv1%2Ffolders%2F%7BId%7D%2Fmove-1.0
      response = HTTP
        .auth(UCASAPI.auth_string)
        .post(
          "#{UCASAPI.base_url}/folders/#{UPLOAD_FOLDER}/files",
          form: { file: HTTP::FormData::File.new(filename) },
        )

      unless response.status.success?
        raise ApiError, "HTTP #{response.status} when uploading to Movit: '#{response}'"
      end
    end

  private

    def csv_as_string
      applications = MatchingDataExport.new.applications
      header_row = MatchingDataExport.csv_header(applications)

      CSV.generate do |rows|
        rows << header_row

        applications.each do |application|
          rows << application.values
        end
      end
    end
  end
end

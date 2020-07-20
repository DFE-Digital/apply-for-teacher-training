module UCASMatching
  class UploadMatchingData
    include Sidekiq::Worker

    def perform
      if ENV['UCAS_USERNAME'].blank?
        Rails.logger.info 'UCAS credentials aren\'t configured, assuming that this this is a test environment. Not uploading data.'
        return
      end

      filename = UCASMatching::MatchingDataFile.new.create_file

      # https://transfer.ucasenvironments.com/swagger/ui/index#/Folders/POSTapi%2Fv1%2Ffolders%2F%7BId%7D%2Fmove-1.0
      response = HTTP
        .auth(UCASAPI.auth_string)
        .post(
          "#{UCASAPI.base_url}/folders/#{UCASAPI.upload_folder}/files",
          form: { file: HTTP::FormData::File.new(filename) },
        )

      unless response.status.success?
        raise ApiError, "HTTP #{response.status} when uploading to Movit: '#{response}'"
      end
    end
  end
end

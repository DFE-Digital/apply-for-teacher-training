module UCASMatching
  # We upload our application data every weekday morning to UCAS so that they
  # can detect candidates who've applied on both services.
  #
  # Kibana dashboard for the logging:
  #
  # https://kibana.logit.io/app/kibana#/dashboard/6966e7e0-cb2d-11ea-8848-73aea0c4ba74
  class UploadMatchingData
    include Sidekiq::Worker

    def perform
      if ENV['UCAS_USERNAME'].blank?
        Rails.logger.info 'UCAS credentials aren\'t configured, assuming that this this is a test environment. Not uploading data.'
        return
      end

      filename = UCASMatching::MatchingDataFile.new.create_file

      Rails.logger.info "Uploading file to UCAS Movit instance: #{filename}"

      # https://transfer.ucasenvironments.com/swagger/ui/index#/Folders/POSTapi%2Fv1%2Ffolders%2F%7BId%7D%2Fmove-1.0
      response = HTTP
        .auth(UCASAPI.auth_string)
        .post(
          "#{UCASAPI.base_url}/folders/#{UCASAPI.upload_folder}/files",
          form: { file: HTTP::FormData::File.new(filename) },
        )

      unless response.status.success?
        Rails.logger.info "HTTP #{response.status} when uploading to Movit: '#{response}'"
        raise ApiError, "HTTP #{response.status} when uploading to Movit: '#{response}'"
      end

      Rails.logger.info 'Successfully uploaded file to UCAS Movit'
    end
  end
end

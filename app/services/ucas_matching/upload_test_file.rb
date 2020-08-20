module UCASMatching
  # Upload a test file to the test environment, so we can simulate ProcessMatchingData.
  class UploadTestFile
    def upload
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S_%z').gsub('+', '')
      filename_prefix = "/tmp/matched_data_#{timestamp}-#{SecureRandom.hex}"
      csv_filename = "#{filename_prefix}.csv"
      zip_filename = "#{filename_prefix}.zip"

      csv_as_string = SafeCSV.generate(
        [[Candidate.first.id, 'Foo']],
        ['Apply candidate ID', 'Something else'],
      )

      File.open(csv_filename, 'w') do |f|
        f.write(csv_as_string)
      end

      Archive::Zip.archive(
        zip_filename,
        csv_filename,
        encryption_codec: Archive::Zip::Codec::TraditionalEncryption,
        password: ENV.fetch('UCAS_DOWNLOAD_ZIP_PASSWORD'),
      )

      # https://transfer.ucasenvironments.com/swagger/ui/index#/Folders/POSTapi%2Fv1%2Ffolders%2F%7BId%7D%2Fmove-1.0
      response = HTTP
        .auth(UCASAPI.auth_string)
        .post(
          "#{UCASAPI.base_url}/folders/#{UCASAPI.download_folder}/files",
          form: { file: HTTP::FormData::File.new(zip_filename) },
        )

      unless response.status.success?
        Rails.logger.info "HTTP #{response.status} when uploading to Movit: '#{response}'"
        raise UCASMatching::APIError, "HTTP #{response.status} when uploading to Movit: '#{response}'"
      end

      Rails.logger.info 'Successfully uploaded file to UCAS Movit'
    end
  end
end

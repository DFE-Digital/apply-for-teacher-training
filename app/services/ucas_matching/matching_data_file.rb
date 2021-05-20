module UCASMatching
  class MatchingDataFile
    # @returns filename
    def create_file
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S_%z').gsub('+', '')
      filename_prefix = "/tmp/dfe_apply_itt_applications_#{timestamp}-#{SecureRandom.hex}"
      csv_filename = "#{filename_prefix}.csv"
      zip_filename = "#{filename_prefix}.zip"

      Rails.logger.info 'Creating new export for UCAS'

      File.open(csv_filename, 'w') do |f|
        f.write(csv_as_string)
      end

      Rails.logger.info "Finished creating export to #{csv_filename}. Archiving..."

      Archive::Zip.archive(
        zip_filename,
        csv_filename,
        encryption_codec: Archive::Zip::Codec::TraditionalEncryption,
        password: ENV.fetch('UCAS_ZIP_PASSWORD'),
      )

      Rails.logger.info "Finished archiving export to #{zip_filename}"

      zip_filename
    end

  private

    def csv_as_string
      applications = MatchingDataExport.new.applications
      header_row = MatchingDataExport.csv_header(applications)
      objects = applications.map(&:values)
      SafeCSV.generate(objects, header_row)
    end
  end
end

require 'csv'
# require 'archive/zip'

module UCASMatching
  class MatchingDataFile
    # @returns filename
    def create_file
      timestamp = Time.zone.now.strftime('%Y%m%d_%H%M%S_%z').gsub('+', '')
      filename_prefix = "/tmp/dfe_apply_itt_applications_#{timestamp}-#{SecureRandom.hex}"
      csv_filename = "#{filename_prefix}.csv"
      zip_filename = "#{filename_prefix}.zip"

      File.open(csv_filename, 'w') do |f|
        f.write(csv_as_string)
      end

      Archive::Zip.archive(
        zip_filename,
        csv_filename,
        encryption_codec: Archive::Zip::Codec::TraditionalEncryption,
        password: ENV.fetch('UCAS_ZIP_PASSWORD'),
      )

      zip_filename
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

require 'csv'

module UCASMatching
  # After UCAS receives our file with applications, they match it against the
  # candidates in their database. They then upload a new zipped file to the
  # DFEApplicantData/matched_dfe_apply_itt_applications folder on Movit.

  # This worker downloads all the files in the folder, and processes them by
  # reading the CSV and updating or creating UCASMatch records, which will be
  # visible to the support team.
  #
  # Kibana dashboard for the logging:
  #
  # https://kibana.logit.io/app/kibana#/dashboard/6966e7e0-cb2d-11ea-8848-73aea0c4ba74
  #
  # It is tested on QA by uploading a test file with UploadTestFile.
  class ProcessMatchingData
    include Sidekiq::Worker

    def perform
      if ENV['UCAS_USERNAME'].blank?
        Rails.logger.info 'UCAS credentials are not configured, assuming that this this is a test environment. Not downloading data.'
        return
      else
        Rails.logger.info 'UCAS credentials configured, starting download and processing.'
      end

      files_in_ucas_movit_folder.each do |movit_file|
        process_file_in_movit_folder(movit_file)
      end

      Rails.logger.info 'UCAS file processing finished'
    rescue StandardError => e
      Rails.logger.info "An error occured: `#{e.inspect}`"
      raise
    end

  private

    def process_file_in_movit_folder(movit_file)
      if Redis.current.sismember('processed-ucas-files', movit_file.fetch('id'))
        Rails.logger.info "Skipping file with ID #{movit_file.fetch('id')} - we've already processed it"
        return
      else
        Rails.logger.info "Downloading file with ID #{movit_file.fetch('id')}"
      end

      working_directory = Rails.root.join('tmp', SecureRandom.hex)
      Dir.mkdir(working_directory)

      response = HTTP.auth(auth_string).get("#{UCASAPI.base_url}/folders/#{UCASAPI.download_folder}/files/#{movit_file.fetch('id')}/download")
      file = HTTP.auth(auth_string).get(response.headers['Location'])
      File.open("#{working_directory}/file.zip", 'wb') { |f| f.write(file.body) }

      Rails.logger.info "File downloaded to `#{working_directory}/file.zip`, extracting.."

      Archive::Zip.extract(
        "#{working_directory}/file.zip",
        working_directory.to_s,
        password: ENV.fetch('UCAS_DOWNLOAD_ZIP_PASSWORD'),
      )

      Rails.logger.info "File extracted to `#{working_directory}`, parsing..."

      Dir.glob("#{working_directory}/*.csv").each do |csv_file|
        process_csv_file(csv_file)
      end

      Redis.current.sadd('processed-ucas-files', movit_file.fetch('id'))
    end

    def files_in_ucas_movit_folder
      response = JSON.parse(HTTP.auth(auth_string).get("#{UCASAPI.base_url}/folders/#{UCASAPI.download_folder}/files"))
      response.fetch('items')
    end

    def auth_string
      @auth ||= UCASAPI.auth_string
    end

    def process_csv_file(file)
      candidates = CSV.read(file, headers: true).map(&:to_h).group_by { |row| row['Apply candidate ID'] }

      updated_matches = 0
      new_matches = 0
      existing_matches = 0

      candidates.each do |candidate_id, matching_data|
        match = UCASMatch.find_or_initialize_by(candidate_id: candidate_id)
        match.matching_data = matching_data

        if match.matching_data_changed?
          match.audit_comment = "Duplicate data updated from file #{file}"

          if match.persisted?
            Rails.logger.info "Found a match for candidate ID #{candidate_id}, updating matching data"
            match.matching_state = 'matching_data_updated'
            updated_matches += 1
          else
            Rails.logger.info "Found a match for candidate ID #{candidate_id}, creating new matching record"
            match.matching_state = 'new_match'
            new_matches += 1
          end

          match.save!
        else
          Rails.logger.info "Found a match for candidate ID #{candidate_id}, but no changes to record"
          existing_matches += 1
        end
      end

      message = "Hello, this is the UCAS matching robot. I've just received a new file from UCAS. It contained #{new_matches} new matches, #{updated_matches} updated matches, and #{existing_matches} matches that we've already seen."
      url = Rails.application.routes.url_helpers.support_interface_path
      SlackNotificationWorker.perform_async(message, url)
    end
  end
end

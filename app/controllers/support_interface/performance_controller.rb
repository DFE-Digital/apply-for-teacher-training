require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def application_timings
      applications = SupportInterface::ApplicationsExport.new.applications
      csv = to_csv(applications)

      render plain: csv
    end

    def submitted_application_choices
      choices = SupportInterface::ApplicationChoicesExport.new.application_choices
      csv = to_csv(choices)

      render plain: csv
    end

    def providers_export
      providers = SupportInterface::ProvidersExport.new.providers
      csv = to_csv(providers)

      render plain: csv
    end

    def referee_survey
      responses = SupportInterface::RefereeSurveyExport.new.call
      csv = to_csv(responses)

      send_data csv, filename: "referee-survey-#{Time.zone.today}.csv", disposition: :attachment
    end

    def candidate_survey
      answers = SupportInterface::CandidateSurveyExport.new.call
      csv = to_csv(answers)

      send_data csv, filename: "candidate-survey-#{Time.zone.today}.csv", disposition: :attachment
    end

    def applications_export_for_ucas
      applications = ApplicationsExportForUCAS.new.applications
      header_row = ApplicationsExportForUCAS.csv_header(applications)
      csv = to_csv(applications, header_row)

      send_data csv, filename: "dfe_apply_itt_applications_#{Time.zone.now.iso8601}.csv", disposition: :attachment
    end

  private

    def to_csv(objects, header_row = nil)
      header_row ||= objects.to_a.first&.keys

      CSV.generate do |rows|
        rows << header_row
        objects&.each do |object|
          rows << object.values
        end
      end
    end
  end
end

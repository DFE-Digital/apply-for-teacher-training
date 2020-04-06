require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def application_timings
      applications = SupportInterface::ApplicationsExport.new.applications

      csv = CSV.generate do |rows|
        rows << applications.first.keys

        applications.each do |a|
          rows << a.values
        end
      end

      render plain: csv
    end

    def submitted_application_choices
      choices = SupportInterface::ApplicationChoicesExport.new.application_choices

      csv = CSV.generate do |rows|
        rows << choices.first.keys

        choices.each do |a|
          rows << a.values
        end
      end

      render plain: csv
    end

    def providers_export
      providers = SupportInterface::ProvidersExport.new.providers

      csv = CSV.generate do |rows|
        rows << providers.first.keys

        providers.each do |a|
          rows << a.values
        end
      end

      render plain: csv
    end

    def referee_survey
      responses = SupportInterface::RefereeSurveyExport.new.call

      csv = CSV.generate do |rows|
        rows << responses&.first&.keys

        responses&.each do |response|
          rows << response.values
        end
      end

      send_data csv, filename: "referee-survey-#{Time.zone.today}.csv", disposition: :attachment
    end

    def candidate_survey
      answers = SupportInterface::CandidateSurveyExport.new.call

      csv = CSV.generate do |rows|
        rows << answers&.first&.keys

        answers&.each do |answer|
          rows << answer.values
        end
      end

      send_data csv, filename: "candidate-survey-#{Time.zone.today}.csv", disposition: :attachment
    end
  end
end

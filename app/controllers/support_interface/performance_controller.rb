require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_stats; end

    def application_timings
      data_export = DataExport.create!(name: 'Application timings', initiator: current_support_user)
      DataExporter.perform_async(ApplicationsExport, data_export.id)

      redirect_to support_interface_data_export_path(data_export)
    end

    def submitted_application_choices
      data_export = DataExport.create!(name: 'Submitted application choices', initiator: current_support_user)
      DataExporter.perform_async(ApplicationChoicesExport, data_export.id)

      redirect_to support_interface_data_export_path(data_export)
    end

    def candidate_journey_tracking
      data_export = DataExport.create!(name: 'Candidate journey tracking', initiator: current_support_user)
      DataExporter.perform_async(CandidateJourneyTrackingExport, data_export.id)

      redirect_to support_interface_data_export_path(data_export)
    end

    def providers_export
      data_export = DataExport.create!(name: 'Providers', initiator: current_support_user)
      DataExporter.perform_async(ProvidersExport, data_export.id)

      redirect_to support_interface_data_export_path(data_export)
    end

    def referee_survey
      responses = SupportInterface::RefereeSurveyExport.new.call
      csv = to_csv(responses)

      send_data csv, filename: "referee-survey-#{Time.zone.today}.csv", disposition: :attachment
    end

    def candidate_survey
      answers = SupportInterface::CandidateSurveyExport.new.call

      if answers.present?
        csv = to_csv(answers)
        send_data csv, filename: "candidate-survey-#{Time.zone.today}.csv", disposition: :attachment
      else
        flash[:warning] = 'No candidates have filled in the survey'

        redirect_to support_interface_performance_path
      end
    end

    def active_provider_users
      provider_users = SupportInterface::ActiveProviderUsersExport.call
      csv = to_csv(provider_users)

      send_data csv, filename: "active-provider-users-#{Time.zone.today}.csv", disposition: :attachment
    end

    def tad_provider_performance
      export_rows = SupportInterface::TADProviderStatsExport.new.call
      csv = to_csv(export_rows)

      send_data csv, filename: "tad-provider-performance-#{Time.zone.today}.csv", disposition: :attachment
    end

    def course_choice_withdrawal
      answers = SupportInterface::CourseChoiceWithdrawalSurveyExport.call

      if answers.present?
        csv = to_csv(answers)
        send_data csv, filename: "course-choice_withdrawl-survey-#{Time.zone.today}.csv", disposition: :attachment
      else
        flash[:warning] = 'No candidates have filled in the survey'

        redirect_to support_interface_performance_path
      end
    end

    def application_references
      references = SupportInterface::ApplicationReferencesExport.call
      header_row = SupportInterface::ApplicationReferencesExport.header_row
      csv = to_csv(references, header_row)

      send_data csv, filename: "application-references-#{Time.zone.today}.csv", disposition: :attachment
    end

    def offer_conditions
      offers = SupportInterface::OfferConditionsExport.new.offers
      csv = to_csv(offers)

      send_data csv, filename: "offer-conditions-#{Time.zone.today}.csv", disposition: :attachment
    end

  private

    def to_csv(objects, header_row = nil)
      header_row ||= objects.to_a.first&.keys
      SafeCSV.generate(objects.map(&:values), header_row)
    end
  end
end

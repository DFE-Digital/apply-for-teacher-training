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

      if answers.present?
        csv = to_csv(answers)
        send_data csv, filename: "candidate-survey-#{Time.zone.today}.csv", disposition: :attachment
      else
        flash[:warning] = 'No candidates have filled in the survey'

        redirect_to support_interface_performance_path
      end
    end

    def applications_export_for_ucas
      if FeatureFlag.active?('download_dataset1_from_support_page')
        applications = ApplicationsExportForUCAS.new.applications
        header_row = ApplicationsExportForUCAS.csv_header(applications)
        csv = to_csv(applications, header_row)

        send_data csv, filename: "dfe_apply_itt_applications_#{Time.zone.now.iso8601}.csv", disposition: :attachment
      else
        # The unauthorized page expects an instance var that's only set in
        # the dfe_sign_in_controller
        @dfe_sign_in_user = dfe_sign_in_user
        render 'support_interface/unauthorized', status: :forbidden
      end
    end

    def active_provider_users
      provider_users = SupportInterface::ActiveProviderUsersExport.call
      csv = to_csv(provider_users)

      send_data csv, filename: "active-provider-users-#{Time.zone.today}.csv", disposition: :attachment
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

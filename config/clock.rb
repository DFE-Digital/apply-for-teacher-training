require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  error_handler { |error| Sentry.capture_exception(error) if defined? Sentry }

  # More-than-hourly jobs

  every(10.minutes, 'IncrementalSyncAllFromTeacherTrainingPublicAPI', skip_first_run: true) do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(true)
  end

  # Hourly jobs

  # StartOfCycleNotificationWorker only works the day the service opens. These two jobs won't run at the same time on the same day.
  every(1.hour, 'SendFindStartOfCycleProviderEmails', at: '**:05') { StartOfCycleNotificationWorker.perform_async('find') }

  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'ChaseReferences', at: '**:20') { ChaseReferences.perform_async }
  every(1.hour, 'DetectInvariantsHourlyCheck', at: '**:30') { DetectInvariantsHourlyCheck.perform_async }
  every(1.hour, 'SendChaseEmailToProviders', at: '**:35') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:40') { SendChaseEmailToCandidatesWorker.perform_async }
  every(1.hour, 'UpdateFeatureMetricsDashboard', at: '**:45') { UpdateFeatureMetricsDashboard.perform_async }

  # Daily jobs
  every(1.day, 'DetectInvariantsDailyCheck', at: '07:00') { DetectInvariantsDailyCheck.perform_async }

  every(1.day, 'SendStatsSummaryToSlack', at: '17:00') { SendStatsSummaryToSlack.new.perform }

  every(1.day, 'Generate export for TAD', at: '23:59') { DataAPI::TADExport.run_daily }

  every(1.day, 'MinisterialReportCandidatesExport', at: '23:59') { SupportInterface::MinisterialReportCandidatesExport.run_daily }
  every(1.day, 'MinisterialReportApplicationsExport', at: '23:59') { SupportInterface::MinisterialReportApplicationsExport.run_daily }

  every(1.day, 'SendEocDeadlineReminderEmailToCandidatesWorker', at: '12:00') { SendEocDeadlineReminderEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendFindHasOpenedEmailToCandidatesWorker', at: '12:00') { SendFindHasOpenedEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendNewCycleStartedEmailToCandidatesWorker', at: '10:00') { SendNewCycleHasStartedEmailToCandidatesWorker.new.perform }

  every(1.day, 'UpdateFraudAuditDashboard', at: '13:00') { UpdateFraudMatchesWorker.perform_async }
  every(1.day, 'TriggerFullSyncIfFindClosed', at: '00:05') { TeacherTrainingPublicAPI::TriggerFullSyncIfFindClosed.call }

  every(7.days, 'FullSyncAllFromTeacherTrainingPublicAPI', at: 'Saturday 00:59') do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false)
  end

  every(1.day, 'VendorIntegrationStatsWorker', at: '09:00', if: ->(t) { t.weekday? }) do
    VendorIntegrationStatsWorker.perform_async('tribal')
    VendorIntegrationStatsWorker.perform_async('ellucian')
    VendorIntegrationStatsWorker.perform_async('unit4')
    VendorIntegrationStatsWorker.perform_async('oracle')
  end

  every(1.day, 'Generate applications export for the External Report', at: '00:00', if: ->(t) { t.day == 1 }) do
    export = DataExport.create!(
      name: 'External report applications',
      export_type: :external_report_applications,
    )
    DataExporter.perform_async(SupportInterface::ExternalReportApplicationsExport, export.id, {})
  end
end

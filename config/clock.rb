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

  every(1.hour, 'SendFindStartOfCycleProviderEmails', at: '**:05') { StartOfCycleNotificationWorker.perform_async }
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'ChaseReferences', at: '**:20') { ChaseReferences.perform_async }
  every(1.hour, 'UpdateOutOfDateProviderIdsOnApplicationChoices', at: '**:20') { UpdateOutOfDateProviderIdsOnApplicationChoices.perform_async }
  every(1.hour, 'UpdateDuplicateMatchesWorker', at: '**:25') { UpdateDuplicateMatchesWorker.perform_async(notify_slack_at: 13) }
  every(1.hour, 'DetectInvariantsHourlyCheck', at: '**:30') { DetectInvariantsHourlyCheck.perform_async }
  every(1.hour, 'SendChaseEmailToProviders', at: '**:35') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:40') { SendChaseEmailToCandidatesWorker.perform_async }

  # Daily jobs
  every(1.day, 'DetectInvariantsDailyCheck', at: '07:00') { DetectInvariantsDailyCheck.perform_async }

  every(1.day, 'SendStatsSummaryToSlack', at: '17:00') { SendStatsSummaryToSlack.new.perform }

  every(1.day, 'Generate export for TAD', at: '23:59') { DataAPI::TADExport.run_daily }

  every(1.day, 'Generate monthly statistics report and exports', at: '00:00') { GenerateMonthlyStatistics.perform_async }

  every(1.day, 'MinisterialReportCandidatesExport', at: '23:50') { SupportInterface::MinisterialReportCandidatesExport.run_daily }
  every(1.day, 'MinisterialReportApplicationsExport', at: '23:53') { SupportInterface::MinisterialReportApplicationsExport.run_daily }

  every(1.day, 'SendEocDeadlineReminderEmailToCandidatesWorker', at: '12:00') { SendEocDeadlineReminderEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendFindHasOpenedEmailToCandidatesWorker', at: '12:00') { SendFindHasOpenedEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendNewCycleStartedEmailToCandidatesWorker', at: '10:00') { SendNewCycleHasStartedEmailToCandidatesWorker.new.perform }

  every(1.day, 'TriggerFullSyncIfFindClosed', at: '00:05') { TeacherTrainingPublicAPI::TriggerFullSyncIfFindClosed.call }
  every(1.day, 'NudgeCandidatesWorker', at: '10:00') { NudgeCandidatesWorker.perform_async }

  every(1.day, 'CancelUnsubmittedApplicationsWorker', at: '00:10') { CancelUnsubmittedApplicationsWorker.perform_async }

  # Weekly jobs
  every(7.days, 'FullSyncAllFromTeacherTrainingPublicAPI', at: 'Saturday 00:59') do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false)
  end

  every(7.days, 'TADSubjectDomicileNationalityExport', at: 'Sunday 23:59') do
    DataAPI::TADSubjectDomicileNationalityExport.run_weekly
  end
  every(7.days, 'ApplicationsBySubjectRouteAndDegreeGradeExport', at: 'Sunday 23:55') { SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport.run_weekly }
  every(7.days, 'ApplicationsByDemographicDomicileAndDegreeClassExport', at: 'Sunday 23:57') { SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.run_weekly }
end

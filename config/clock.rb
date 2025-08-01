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

  every(15.minutes, 'FindACandidate::PopulatePoolWorker', skip_first_run: true) do
    FindACandidate::PopulatePoolWorker.perform_async
  end

  # Hourly jobs

  every(1.hour, 'FindACandidate::PoolInviteChaserWorker', at: '**:35', skip_first_run: true) { FindACandidate::PoolInviteChaserWorker.perform_async }
  every(1.hour, 'SendFindStartOfCycleProviderEmails', at: '**:05') { StartOfCycleNotificationWorker.perform_async }
  every(1.hour, 'ProcessStaleApplications', at: '**:10') do
    ProcessStaleApplicationsWorker.perform_async
  end
  every(1.hour, 'ChaseReferences', at: '**:20') { ChaseReferences.perform_async }
  every(1.hour, 'UpdateOutOfDateProviderIdsOnApplicationChoices', at: '**:20') { UpdateOutOfDateProviderIdsOnApplicationChoices.perform_async }
  every(1.hour, 'UpdateDuplicateMatchesWorker', at: '**:25') { UpdateDuplicateMatchesWorker.perform_async('notify_slack_at' => 13) }
  every(1.hour, 'DetectInvariantsHourlyCheck', at: '**:30') { DetectInvariantsHourlyCheck.perform_async }
  every(1.hour, 'Adviser::FetchTeachingSubjectsWorker', at: '**:15') { Adviser::FetchTeachingSubjectsWorker.perform_async }

  # Daily jobs
  every(1.day, 'DeleteExpiredSessionsWorker', at: '5:01') { DeleteExpiredSessionsWorker.perform_async }
  every(1.day, 'DeleteAllDrafts', at: '4:01') { DeleteAllDraftsWorker.perform_async }
  every(1.day, 'Chasers::Candidate::OfferWorker', at: '10:30') { Chasers::Candidate::OfferWorker.perform_async }

  every(1.day, 'DetectInvariantsDailyCheck', at: '07:00') { DetectInvariantsDailyCheck.perform_async }

  every(1.day, 'Generate export for TAD', at: '23:59') { DataAPI::TADExport.run_daily }

  every(1.day, 'Generate monthly statistics report and exports', at: '05:00') { GenerateMonthlyStatistics.perform_async }

  every(1.day, 'MinisterialReportCandidatesExport', at: '23:50') { SupportInterface::MinisterialReportCandidatesExport.run_daily }
  every(1.day, 'MinisterialReportApplicationsExport', at: '23:53') { SupportInterface::MinisterialReportApplicationsExport.run_daily }

  every(1.day, 'SendEocDeadlineReminderEmailToCandidatesWorker', at: '12:00') { SendEocDeadlineReminderEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendFindHasOpenedEmailToCandidatesWorker', at: '12:00') { SendFindHasOpenedEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendNewCycleStartedEmailToCandidatesWorker', at: '10:00') { SendNewCycleHasStartedEmailToCandidatesWorker.new.perform }
  every(1.day, 'EndOfCycle::SendRejectByDefaultReminderToProvidersWorker') { EndOfCycle::SendRejectByDefaultReminderToProvidersWorker.new.perform }
  every(1.day, 'EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesWorker', at: '09:00') { EndOfCycle::SendApplicationDeadlineHasPassedEmailToCandidatesWorker.new.perform }
  every(1.day, 'EndOfCycle:SendRejectByDefaultExplainerToCandidatesWorker', at: '09:01') { EndOfCycle::SendRejectByDefaultExplainerEmailToCandidatesWorker.new.perform }
  every(1.day, 'Candidate::PoolEligibleApplicationFormWorker', at: '09:02') { Candidate::PoolEligibleApplicationFormWorker.new.perform }

  every(1.day, 'TriggerFullSyncIfFindClosed', at: '00:05') { TeacherTrainingPublicAPI::TriggerFullSyncIfFindClosed.call }
  every(1.day, 'NudgeCandidatesWorker', at: '10:00') { NudgeCandidatesWorker.perform_async }
  every(1.day, 'SendApplyToAnotherCourseWhenInactiveEmailToCandidatesWorker', at: '10:00') { SendApplyToAnotherCourseWhenInactiveEmailToCandidatesWorker.perform_async }
  every(1.day, 'SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesWorker', at: '10:00') { SendApplyToMultipleCoursesWhenInactiveEmailToCandidatesWorker.perform_async }
  every(1.day, 'DfE::Analytics::EntityTableCheckJob', at: '00:30') { DfE::Analytics::EntityTableCheckJob.perform_later }

  # End of cycle application choice status jobs
  # Changes unsubmitted application choices to 'application_not_sent'
  every(1.day, 'EndOfCycle::CancelUnsubmittedApplicationsWorker', at: '19:00') { EndOfCycle::CancelUnsubmittedApplicationsWorker.perform_async }
  # Reject any application choices that are still awaiting provider decision (interviewing, inactive, and awaiting decision)
  every(1.day, 'EndOfCycle::RejectByDefaultWorker', at: '00:01') { EndOfCycle::RejectByDefaultWorker.perform_async }
  # Decline any offers that are awaiting candidate decision
  every(1.day, 'EndOfCycle::DeclineByDefaultWorker', at: '01:01') { EndOfCycle::DeclineByDefaultWorker.perform_async }

  # Daily jobs - mon-thurs only
  every(1.day, 'SendStatsSummaryToSlack', at: '17:00', if: ->(period) { period.wday.between?(1, 4) }) { SendStatsSummaryToSlack.new.perform }

  # Weekly jobs
  every(7.days, 'FullSyncAllFromTeacherTrainingPublicAPI', at: 'Saturday 00:59') do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false)
  end

  every(7.days, 'TADSubjectDomicileNationalityExport', at: 'Sunday 23:59') do
    DataAPI::TADSubjectDomicileNationalityExport.run_weekly
  end

  every(7.days, 'SendWeeklyStatsSummaryToSlack', at: 'Friday 11:00') { SendWeeklyStatsSummaryToSlack.new.perform }

  every(7.days, 'ApplicationsBySubjectRouteAndDegreeGradeExport', at: 'Sunday 23:55') { SupportInterface::ApplicationsBySubjectRouteAndDegreeGradeExport.run_weekly }
  every(7.days, 'ApplicationsByDemographicDomicileAndDegreeClassExport', at: 'Sunday 23:57') { SupportInterface::ApplicationsByDemographicDomicileAndDegreeClassExport.run_weekly }

  every(7.days, 'Schedule Recruitment Performance reports', at: 'Monday 05:30', if: ->(_period) { RecruitmentPerformanceReportTimetable.report_season? }) { Publications::RecruitmentPerformanceReportScheduler.new.call }
end

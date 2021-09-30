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
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'ChaseReferences', at: '**:20') { ChaseReferences.perform_async }
  every(1.hour, 'DetectInvariantsHourlyCheck', at: '**:30') { DetectInvariantsHourlyCheck.perform_async }
  every(1.hour, 'SendChaseEmailToProviders', at: '**:35') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:40') { SendChaseEmailToCandidatesWorker.perform_async }
  every(1.hour, 'UpdateFeatureMetricsDashboard', at: '**:45') { UpdateFeatureMetricsDashboard.perform_async }

  # Daily jobs
  every(1.day, 'UCASMatching::UploadMatchingData', at: '06:23') do
    if Time.zone.today.weekday?
      UCASMatching::UploadMatchingData.perform_async
    end
  end

  every(1.day, 'DetectInvariantsDailyCheck', at: '07:00') { DetectInvariantsDailyCheck.perform_async }

  every(1.day, 'UCASMatching::ProcessMatchingData', at: '10:00') do
    if Time.zone.today.weekday?
      if HostingEnvironment.qa?
        UCASMatching::UploadTestFile.new.upload
      end

      UCASMatching::ProcessMatchingData.perform_async
    end
  end

  every(1.day, 'UCASIntegrationCheck', at: '11:00') do
    if HostingEnvironment.production? && Time.zone.yesterday.weekday?
      UCASIntegrationCheck.perform_async
    end
  end

  every(1.day, 'SendStatsSummaryToSlack', at: '17:00') { SendStatsSummaryToSlack.new.perform }

  every(1.day, 'Generate export for TAD', at: '23:59') { DataAPI::TADExport.run_daily }

  every(1.day, 'SendEocDeadlineReminderEmailToCandidatesWorker', at: '12:00') { SendEocDeadlineReminderEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendFindHasOpenedEmailToCandidatesWorker', at: '12:00') { SendFindHasOpenedEmailToCandidatesWorker.new.perform }
  every(1.day, 'SendNewCycleStartedEmailToCandidatesWorker', at: '12:00') { SendNewCycleHasStartedEmailToCandidatesWorker.new.perform }

  every(7.days, 'FullSyncAllFromTeacherTrainingPublicAPI', at: 'Saturday 00:59') do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async(false)
  end
end

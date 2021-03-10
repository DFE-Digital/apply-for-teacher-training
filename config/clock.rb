require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  error_handler { |error| Raven.capture_exception(error) if defined? Raven }

  every(15.minutes, 'SyncAllFromFind') { SyncAllFromFind.perform_async }

  every(1.hour, 'DetectInvariants') { DetectInvariants.perform_async }
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'ChaseReferences', at: '**:20') { ChaseReferences.perform_async }
  every(1.hour, 'SendChaseEmailToProviders', at: '**:35') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:40') { SendChaseEmailToCandidatesWorker.perform_async }
  every(1.hour, 'UpdateFeatureMetricsDashboard', at: '**:45') { UpdateFeatureMetricsDashboard.perform_async }

  every(1.day, 'Generate export for TAD', at: '23:59') { DataAPI::TADExport.run_daily }

  every(1.day, 'UCASMatching::UploadMatchingData', at: '06:23') do
    if Time.zone.today.weekday?
      UCASMatching::UploadMatchingData.perform_async
    end
  end

  every(1.day, 'UCASMatching::ProcessMatchingData', at: '10:00') do
    if Time.zone.today.weekday?
      if HostingEnvironment.qa?
        UCASMatching::UploadTestFile.new.upload
      end

      UCASMatching::ProcessMatchingData.perform_async
    end
  end

  every(1.day, 'UCASIntegrationCheck', at: '11:00') do
    if HostingEnvironment.production?
      UCASIntegrationCheck.perform_async if Time.zone.yesterday.weekday?
    end
  end

  every(1.hour, 'SyncAllFromTeacherTrainingPublicAPI') do
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  every(1.day, 'Generate export for Notifications', at: '23:57') do
    data_export = DataExport.create!(name: 'Daily export of notifications breakdown')
    DataExporter.perform_async(SupportInterface::NotificationsExport, data_export.id)
  end
end

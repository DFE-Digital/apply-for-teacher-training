require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(1.minute, 'ClockworkCheck') { ClockworkCheck.perform_async }
  every(15.minutes, 'SyncAllFromFind') { SyncAllFromFind.perform_async }
  every(1.hour, 'DetectInvariants') { DetectInvariants.perform_async }
  every(1.hour, 'SendApplicationsToProvider', at: '**:05') { SendApplicationsToProviderWorker.perform_async }
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }

  every(1.hour, 'SendReferenceChaseEmailToBothParties', at: '**:20') { SendReferenceChaseEmailToBothPartiesWorker.perform_async }
  every(1.hour, 'AskCandidatesForNewReferees', at: '**:25') { AskCandidatesForNewRefereesWorker.perform_async }
  every(1.hour, 'SendAdditionalReferenceChaseEmailToCandidates', at: '**:30') { SendAdditionalReferenceChaseEmailToBothPartiesWorker.perform_async }

  every(1.hour, 'SendChaseEmailToProviders', at: '**:35') { SendChaseEmailToProvidersWorker.perform_async }
  every(1.hour, 'SendChaseEmailToCandidates', at: '**:40') { SendChaseEmailToCandidatesWorker.perform_async }
  every(1.hour, 'SendCourseFullNotifications', at: '**:45') { SendCourseFullNotificationsWorker.perform_async }

  every(1.day, 'RejectAwaitingReferencesCourseChoices', at: '00:01', if: ->(t) { t.to_date == EndOfCycleTimetable.date(:apply_2_deadline) + 1 }) { RejectAwaitingReferencesCourseChoicesWorker.perform_async }
  every(1.day, 'CarryOverUnsubmittedApplications', at: '00:01', if: ->(t) { t.to_date == EndOfCycleTimetable.date(:apply_reopens) }) { CarryOverUnsubmittedApplicationsWorker.perform_async }

  every(1.day, 'UCASMatching::UploadMatchingData', at: '06:23') do
    if Time.zone.today.weekday?
      UCASMatching::UploadMatchingData.perform_async
    end
  end

  every(1.day, 'UCASMatching::ProcessMatchingData', at: '9:00') do
    if Time.zone.today.weekday?
      if HostingEnvironment.qa?
        UCASMatching::UploadTestFile.new.upload
      end

      UCASMatching::ProcessMatchingData.perform_async
    end
  end
end

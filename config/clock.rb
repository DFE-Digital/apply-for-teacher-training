require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(5.minutes, 'ClockworkCheck') { ClockworkCheck.perform_async }
  every(15.minutes, 'SyncAllFromFind') { SyncAllFromFind.perform_async }
  every(1.hour, 'DetectInvariants') { DetectInvariants.perform_async }
  every(1.hour, 'SendApplicationsToProvider', at: '**:05') { SendApplicationsToProviderWorker.perform_async }
  every(1.hour, 'RejectApplicationsByDefault', at: '**:10') { RejectApplicationsByDefaultWorker.perform_async }
  every(1.hour, 'DeclineOffersByDefault', at: '**:15') { DeclineOffersByDefaultWorker.perform_async }
  every(1.hour, 'SendChaseEmailToReferees', at: '**:20') { SendChaseEmailToRefereesWorker.perform_async }
end

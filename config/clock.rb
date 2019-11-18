require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(5.minutes, 'ClockworkCheck') { ClockworkCheck.perform_async }
  every(15.minutes, 'SyncFromFind') { SyncFromFind.perform_async }
  every(1.hour, 'SendApplicationsToProvider', at: '**:05') { SendApplicationsToProviderWorker.perform_async }
end

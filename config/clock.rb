require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(5.minutes, 'ClockworkCheck') { ClockworkCheck.perform_async }
  every(1.day, 'SendApplicationsToProvider', at: ['01:00', '03:00', '05:00']) { SendApplicationsToProvider.perform_async }
end

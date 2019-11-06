require './config/boot'
require './config/environment'

require 'clockwork'

class Clock
  include Clockwork

  every(5.minutes, 'ClockworkCheck') { ClockworkCheck.perform_async }
end

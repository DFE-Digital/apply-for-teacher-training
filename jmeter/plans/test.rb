require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i

test do
  # Easiest way to adjust the load is adjusting this
  random_timer 100, 1900 * WAIT_FACTOR

  threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 300 do
    visit name: 'Go to Manage', url: BASEURL + '/provider?jmeter=true'
  end

  threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 300 do
    visit name: 'Go to Apply', url: BASEURL + '/candidate/account?jmeter=true'
  end
end.jmx

require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')

test do
  threads count: 1, continue_forever: true, duration: 300 do
    visit name: 'Go to Manage', url: BASEURL + '/provider?jmeter=true'
    think_time 1000, 1
  end

  threads count: 1, continue_forever: true, duration: 300 do
    think_time 500, 1
    visit name: 'Go to Apply', url: BASEURL + '/candidate/account?jmeter=true'
    think_time 500, 1
  end
end.jmx

require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i

def log_in(user_id)
  visit name: 'Provider user signs in', url: "#{BASEURL}/provider" do
    extract name: 'csrf-token', regex: 'name="csrf-token" content="(.+?)"'
  end
  visit name: 'Go to sign in', url: "#{BASEURL}/provider/sign-in"
  submit name: 'Authenticate', url: "#{BASEURL}/auth/developer/callback", fill_in: { 'uid' => user_id }
end

def provider_codes
  File.read('plans/provider_codes.txt').split
end

THREAD_CONFIG = ENV.fetch('JMETER_THREAD_CONFIG', '1').split(',').map(&:to_i)
THREADS_PER_SCENARIO = (0..5).map { |i| THREAD_CONFIG[i] || 1 }

test do
  cookies clear_each_iteration: true

  # Easiest way to adjust the load is adjusting this
  random_timer 1000, 300000 * WAIT_FACTOR

  # Expected Oct usage per hour: 50 users, 12 sessions/user, 5 minutes per session
  # Providers on average have 2-3 users, but re-using same user for each provider is ok
  # Section below must have 50 uids, each belonging to a different provider
  provider_codes.each do |uid|
    # The total number of sessions for each uid (below) should be 6

    # See interviewing application and interview information
    threads count: THREADS_PER_SCENARIO[0], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by interviewing', url: "#{BASEURL}/provider/applications?commit=Apply+filters&status%5B%5D=interviewing" do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load interviewing application', url: "#{BASEURL}/provider/applications/${application_id}"
      visit name: 'See application interviews', url: "#{BASEURL}/provider/applications/${application_id}/interviews"
    end

    # Start making an offer
    threads count: THREADS_PER_SCENARIO[1], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by awaiting_provider_decision', url: "#{BASEURL}/provider/applications?commit=Apply+filters&status%5B%5D=awaiting_provider_decision" do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load received application', url: "#{BASEURL}/provider/applications/${application_id}"
      visit name: 'Load make decision page', url: "#{BASEURL}/provider/applications/${application_id}/decision/new" do
        extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      end
      submit(
        name: 'Start make offer flow',
        url: "#{BASEURL}/provider/applications/${application_id}/decision",
        DO_MULTIPART_POST: 'true',
        fill_in: {
          'provider_interface_offer_wizard[decision]' => 'make_offer',
          'authenticity_token' => '${authenticity_token}',
          commit: 'Continue',
        },
      )
    end

    # See rejected application
    threads count: THREADS_PER_SCENARIO[2], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by rejected', url: "#{BASEURL}/provider/applications?commit=Apply+filters&status%5B%5D=rejected" do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load rejected application', url: "#{BASEURL}/provider/applications/${application_id}"
      visit name: 'View application timeline', url: "#{BASEURL}/provider/applications/${application_id}/timeline"
      visit name: 'View application notes', url: "#{BASEURL}/provider/applications/${application_id}/notes"
    end

    # See provider interview schedule
    threads count: THREADS_PER_SCENARIO[3], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'See interview schedule', url: "#{BASEURL}/provider/interview-schedule"
      visit name: 'See past interview schedule', url: "#{BASEURL}/provider/interview-schedule/past"
    end

    # See provider activity log
    threads count: THREADS_PER_SCENARIO[4], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Load activity log', url: "#{BASEURL}/provider/activity"
    end

    # Data export
    threads count: THREADS_PER_SCENARIO[5], rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Load provider data export form', url: "#{BASEURL}/provider/applications/data-export/new"
      visit name: 'Download data export', url: "#{BASEURL}/provider/applications/data-export?provider_interface_application_data_export_form[recruitment_cycle_years][]=&provider_interface_application_data_export_form[recruitment_cycle_years][]=2021&provider_interface_application_data_export_form[recruitment_cycle_years][]=2020&provider_interface_application_data_export_form[application_status_choice]=all&provider_interface_application_data_export_form[statuses][]=" do
        with_gzip
      end
    end
  end
end.jmx

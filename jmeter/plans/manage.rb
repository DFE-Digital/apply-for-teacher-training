require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i

def log_in(user_id)
  visit name: 'Provider user signs in', url: BASEURL + '/provider' do
    extract name: 'csrf-token', regex: 'name="csrf-token" content="(.+?)"'
  end
  visit name: 'Go to sign in', url: BASEURL + '/provider/sign-in'
  submit name: 'Authenticate', url: BASEURL + '/auth/developer/callback',
    fill_in: { 'uid' => user_id }
end

test do
  cookies clear_each_iteration: true

  # Easiest way to adjust the load is adjusting this
  random_timer 1000, 300000 * WAIT_FACTOR

  # Expected Oct usage per hour: 50 users, 12 sessions/user, 5 minutes per session
  # Providers on average have 2-3 users, but re-using same user for each provider is ok
  # Section below must have 50 uids, each belonging to a different provider
  %w[
    2KL 28E 2BD 2KM 1XO B28 1KN 1E5 1CS 1AV
    1MN 2FR 2JH 1NA B38 1K2 2CG 13E 19C B25
    1R3 25F 17U 2CF 1QN B20 14B 2KH 1PE 2BU
    1JH 1KH 1HQ 1Y1 2AT 2CJ 2KA 1JD 24R 2AX
    1F6 135 2BP 24L 1KU C10 1LA 1UH 2GG 18C
  ].each do |uid|
    # The total number of sessions for each uid (below) should be 6

    # See interviewing application and interview information
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by interviewing', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=interviewing' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load interviewing application', url: BASEURL + '/provider/applications/${application_id}'
      visit name: 'See application interviews', url: BASEURL + '/provider/applications/${application_id}/interviews'
    end

    # Start making an offer
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by awaiting_provider_decision', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=awaiting_provider_decision' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load received application', url: BASEURL + '/provider/applications/${application_id}'
      visit name: 'Load make decision page', url: BASEURL + '/provider/applications/${application_id}/decision/new' do
        extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      end
      submit name: 'Start make offer flow', url: BASEURL + '/provider/applications/${application_id}/decision',
        'DO_MULTIPART_POST': 'true',
        fill_in: {
          'provider_interface_offer_wizard[decision]' => 'make_offer',
          'authenticity_token' => '${authenticity_token}',
          commit: 'Continue'
        }
    end

    # See rejected application
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Filter by rejected', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=rejected' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      visit name: 'Load rejected application', url: BASEURL + '/provider/applications/${application_id}'
      visit name: 'View application timeline', url: BASEURL + '/provider/applications/${application_id}/timeline'
      visit name: 'View application notes', url: BASEURL + '/provider/applications/${application_id}/notes'
    end

    # See provider interview schedule
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'See interview schedule', url: BASEURL + '/provider/interview-schedule'
      visit name: 'See past interview schedule', url: BASEURL + '/provider/interview-schedule/past'
    end

    # See provider activity log
    threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Load activity log', url: BASEURL + '/provider/activity'
    end

    # Data export
     threads count: 1, rampup: RAMPUP, continue_forever: true, duration: 3600 do
      log_in uid
      visit name: 'Load provider data export form', url: BASEURL + '/provider/applications/data-export/new' do
        extract name: 'provider_id', regex: 'value="(\d+)" name="provider_interface_application_data_export_form\[provider_ids\]', match_number: 0
      end
      visit name: 'Download data export', url: BASEURL + '/provider/applications/data-export?provider_interface_application_data_export_form[recruitment_cycle_years][]=&provider_interface_application_data_export_form[recruitment_cycle_years][]=2021&provider_interface_application_data_export_form[recruitment_cycle_years][]=2020&provider_interface_application_data_export_form[application_status_choice]=all&provider_interface_application_data_export_form[statuses][]=&provider_interface_application_data_export_form[provider_ids][]=&provider_interface_application_data_export_form[provider_ids][]=${provider_id}&commit=Export+data+(CSV)'
    end
  end
end.jmx

require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')

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

  # Expected Oct usage per hour: 50 users, 12 sessions/user, 5 minutes per session
  # Providers on average have 2-3 users
  # Section below must have 25 uids, each belonging to a different provider
  %w[
    dev-support
  ].each do |uid|

    # Each thread below must take 5 minutes
    # The total number of sessions for each uid (below) should be 12

    # See interviewing application and interview information
    threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 3000
      visit name: 'Filter by interviewing', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=interviewing' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      think_time 2000
      visit name: 'Load interviewing application', url: BASEURL + '/provider/applications/${application_id}'
      think_time 1000
      visit name: 'See application interviews', url: BASEURL + '/provider/applications/${application_id}/interviews'
      think_time 295000
    end

    # Start making an offer
    threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 1000
      visit name: 'Filter by awaiting_provider_decision', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=awaiting_provider_decision' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      think_time 1000
      visit name: 'Load received application', url: BASEURL + '/provider/applications/${application_id}'
      think_time 1000
      visit name: 'Load make decision page', url: BASEURL + '/provider/applications/${application_id}/decision/new' do
        extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      end
      think_time 1000
      submit name: 'Start make offer flow', url: BASEURL + '/provider/applications/${application_id}/decision',
        'DO_MULTIPART_POST': 'true',
        fill_in: {
          'provider_interface_offer_wizard[decision]' => 'make_offer',
          'authenticity_token' => '${authenticity_token}',
          commit: 'Continue'
        }
      think_time 295000
    end

    # See rejected application
    threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 2000
      visit name: 'Filter by rejected', url: BASEURL + '/provider/applications?commit=Apply+filters&status%5B%5D=rejected' do
        extract name: 'application_id', regex: 'href="/provider/applications/(\d+)"', match_number: 0
      end
      think_time 1000

      visit name: 'Load rejected application', url: BASEURL + '/provider/applications/${application_id}'
      think_time 1000
      visit name: 'View application timeline', url: BASEURL + '/provider/applications/${application_id}/timeline'
      think_time 1000
      visit name: 'View application notes', url: BASEURL + '/provider/applications/${application_id}/notes'
      think_time 295000
    end

    # See provider interview schedule
    threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 3000
      visit name: 'See interview schedule', url: BASEURL + '/provider/interview-schedule'
      think_time 3000
      visit name: 'See past interview schedule', url: BASEURL + '/provider/interview-schedule/past'
      think_time 295000
    end

    # See provider activity log
    threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 10000
      visit name: 'Load activity log', url: BASEURL + '/provider/activity'
      think_time 290000
    end

    # Data export
     threads count: 2, continue_forever: true, duration: 3600 do
      log_in uid
      think_time 3000
      visit name: 'Load provider data export form', url: BASEURL + '/provider/applications/data-export/new' do
        extract name: 'provider_id', regex: 'value="(\d+)" name="provider_interface_application_data_export_form\[provider_ids\]', match_number: 0
      end
      think_time 2000
      visit name: 'Download data export', url: BASEURL + '/provider/applications/data-export?provider_interface_application_data_export_form[recruitment_cycle_years][]=&provider_interface_application_data_export_form[recruitment_cycle_years][]=2021&provider_interface_application_data_export_form[recruitment_cycle_years][]=2020&provider_interface_application_data_export_form[application_status_choice]=all&provider_interface_application_data_export_form[statuses][]=&provider_interface_application_data_export_form[provider_ids][]=&provider_interface_application_data_export_form[provider_ids][]=${provider_id}&commit=Export+data+(CSV)'
      think_time 295000
    end
  end
end.jmx

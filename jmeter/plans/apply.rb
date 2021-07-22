require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f

def url(path)
  BASEURL + path
end

# 975 concurrent users, 15 minute run time
test do
  cookies clear_each_iteration: true
  view_results_tree

  random_timer 100, 900 * WAIT_FACTOR
  thread_count = 975

  threads count: thread_count, continue_forever: true, duration: 900 do
    #-> Sign up
    visit name: 'Account page', url: url('/candidate/account') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'Account page - choose no existing account', url: url('/candidate/account'),
      fill_in: {
        'candidate_interface_create_account_or_sign_in_form[existing_account]' => 'false',
        'authenticity_token' => '${authenticity_token}',
      }
    )

    visit name: 'Sign up page', url: url('/candidate/sign-up') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'Sign up page - submit email', url: url('/candidate/sign-up'),
      fill_in: {
        'candidate_interface_sign_up_form[email_address]': '${__threadNum}' + '@loadtest.example.com',
        'candidate_interface_sign_up_form[accept_ts_and_cs][]': '',
        'candidate_interface_sign_up_form[accept_ts_and_cs]': 'true',
        'authenticity_token': '${authenticity_token}',
        'commit': 'Continue',
      }
    ) do
      # Assume that an authentication bypass is present which redirects to the magic link page at this point
      extract name: 'sign_in_token', xpath: '//input[@type="hidden" and @name="token"]/@value', tolerant: true
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    #-> Sign in
    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'Confirm authentication - continue', url: url('/candidate/sign-in/confirm'),
      fill_in: {
        'authenticity_token': '${authenticity_token}',
        'token': '${sign_in_token}',
        'commit': 'Continue',
      }
    )

    #-> Partially navigate through course choice flow
    visit name: 'Do you know which course?', url: url('/candidate/application/courses/choose') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'Do you know which course? - say yes', url: url('/candidate/application/courses/choose'),
      fill_in: {
        'candidate_interface_course_chosen_form[choice]' => 'yes',
        'authenticity_token' => '${authenticity_token}',
        'commit' => 'Continue',
      }
    )

    visit name: 'Which training provider?', url: url('/candidate/application/courses/provider')

    #-> View several other sections of the form
    visit name: 'References', url: url('/candidate/application/references/start')
    visit name: 'Back to application', url: url('/candidate/application')
    visit name: 'GCSE English', url: url('/candidate/application/gcse/english')
    visit name: 'Back to application', url: url('/candidate/application')
    visit name: 'Work history', url: url('/candidate/application/restructured-work-history')
    visit name: 'Back to application', url: url('/candidate/application')
    visit name: 'Personal statement', url: url('/candidate/application/personal-statement')
  end
end.jmx

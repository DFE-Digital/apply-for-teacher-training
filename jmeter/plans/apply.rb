require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')

def url(path)
  BASEURL + path
end

# 975 concurrent users, ~7 minutes per session
test do
  cookies clear_each_iteration: true
  thread_count = 975

  threads count: thread_count, continue_forever: true, duration: 420 do
    #-> Sign up
    visit name: 'Account page', url: url('/candidate/account') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end
    think_time 2000
    submit(
      name: 'Account page - create an account', url: url('/candidate/account'),
      fill_in: {
        'candidate_interface_create_account_or_sign_in_form[existing_account]' => 'false',
        'authenticity_token' => '${authenticity_token}',
      }
    )
    think_time 1000
    visit name: 'Sign up page', url: url('/candidate/sign-up') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end
    think_time 2000
    submit(
      name: 'Sign up page - submit email', url: url('/candidate/account'),
      fill_in: {
        'authenticity_token': '${authenticity_token}',
        'candidate_interface_sign_up_form[email_address]': '${__threadNum}' + '@loadtest.example.com',
        'candidate_interface_sign_up_form[accept_ts_and_cs][]': '',
        'candidate_interface_sign_up_form[accept_ts_and_cs]': 'true',
        'commit': 'Continue',
      }
    )
    think_time 1000

    #-> Sign in
    visit name: 'Account page', url: url('/candidate/account') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end
    think_time 2000
    submit(
      name: 'Account page - sign in', url: url('/candidate/account'),
      fill_in: {
        'candidate-interface-create-account-or-sign-in-form-email-field' => '${__threadNum}' + '@loadtest.example.com',
        'authenticity_token' => '${authenticity_token}',
      }
    )
    think_time 1000
    # TODO: add a bypass to our auth logic that immediately signs in @loadtest.example.com email addresses

    #-> Partially navigate through course choice flow
    visit name: 'Do you know which course?', url: url('/candidate/application/courses/choose') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end
    think_time 2000
    submit(
      name: 'Do you know which course? - say yes', url: url('/candidate/account'),
      fill_in: {
        'candidate_interface_course_chosen_form[choice]' => 'yes',
        'authenticity_token' => '${authenticity_token}',
        'commit' => 'Continue',
      }
    )
    think_time 1000
    visit name: 'Which training provider?', url: url('/candidate/application/courses/provider')
    think_time 2000

    #-> View several other sections of the form
    visit name: 'References', url: url('/candidate/application/references/start')
    think_time 2000
    visit name: 'Back to application', url: url('/candidate/application')
    think_time 2000
    visit name: 'GCSE English', url: url('/candidate/application/gcse/english')
    think_time 2000
    visit name: 'Back to application', url: url('/candidate/application')
    think_time 2000
    visit name: 'Work history', url: url('/candidate/application/restructured-work-history')
    think_time 2000
    visit name: 'Back to application', url: url('/candidate/application')
    think_time 2000
    visit name: 'Personal statement', url: url('/candidate/application/personal-statement')
    think_time 2000
  end
end

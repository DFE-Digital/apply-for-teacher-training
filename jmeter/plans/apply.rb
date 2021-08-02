require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
THREAD_COUNT = ENV.fetch('JMETER_THREAD_COUNT', 200).to_i
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i

def url(path)
  BASEURL + path
end

test do
  cookies clear_each_iteration: true
  view_results_tree

  thread_count = THREAD_COUNT
  random_timer 1000, 2000 * WAIT_FACTOR
  csv_data_set_config filename: 'jmeter-courses.csv'

  threads count: thread_count, rampup: RAMPUP, continue_forever: true, duration: 3600 do
    #-> Sign up
    visit name: 'Account page', url: url('/candidate/account') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'

      jsr223_preprocessor(
        name: 'Candidate UUID',
        script: 'vars.put("candidate_uuid", UUID.randomUUID().toString())',
        language: 'groovy',
      )
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

    # Simulate the candidate arriving from Find by including course params in the url
    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'Sign up page - submit email', url: url('/candidate/sign-up?courseCode=${courseCode}&providerCode=${providerCode}'),
      fill_in: {
        'candidate_interface_sign_up_form[email_address]': '${candidate_uuid}' + '@loadtest.example.com',
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
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      extract name: 'course_id', regex: 'application/courses/confirm-selection/(\d+)'
    end

    #-> Confirm course selection identified by earlier Find params
    submit(
      'DO_MULTIPART_POST': 'true',
      name: 'You selected a course - confirm course selection', url: url('/candidate/application/courses/complete-selection/${course_id}'),
      fill_in: {
        'authenticity_token': '${authenticity_token}',
        "candidate_interface_course_selection_form[confirm]": "true"
      }
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      extract name: 'provider_id', regex: 'application/courses/provider/(\d+)/'

      # Extract study mode params if that's the page we're on
      extract name: 'study_mode_page_title', regex: '(Full time or part time)'
      extract name: 'study_mode', regex: 'value="(full_time)" name="candidate_interface_pick_study_mode_form\[study_mode\]"'

      # Extract site params if that's the page we're on
      extract name: 'site_selection_page_title', regex: '(Which location are you applying to)'
      extract name: 'course_option_id', regex: 'value="(\d+)" name="candidate_interface_pick_site_form\[course_option_id\]"'
    end

    #-> Choose study mode if on study mode page
    if_controller(name: 'Choose study mode if present', condition: '${__groovy(vars.get("study_mode_page_title") != null)}') do
      submit(
        'DO_MULTIPART_POST': 'true',
        name: 'Study mode - choose first option', url: url('/candidate/application/courses/provider/${provider_id}/courses/${course_id}'),
        fill_in: {
          'authenticity_token': '${authenticity_token}',
          'candidate_interface_pick_study_mode_form[study_mode]': '${study_mode}',
        }
      ) do
        extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
        extract name: 'provider_id', regex: 'application/courses/provider/(\d+)/'

        extract name: 'site_selection_page_title', regex: '(Which location are you applying to)'
        extract name: 'course_option_id', regex: 'value="(\d+)" name="candidate_interface_pick_site_form\[course_option_id\]"'

        jsr223_postprocessor name: 'Clear study mode page title var', script: 'vars.remove("study_mode_page_title")', language: 'groovy'
      end
    end

    #-> Choose site if on site page
    if_controller(name: 'Choose site if present', condition: '${__groovy(vars.get("site_selection_page_title") != null)}') do
      submit(
        'DO_MULTIPART_POST': 'true',
        name: 'Site - choose first option', url: url('/candidate/application/courses/provider/${provider_id}/courses/${course_id}/full_time/'),
        fill_in: {
          'authenticity_token': '${authenticity_token}',
          'candidate_interface_pick_site_form[course_option_id]': '${course_option_id}',
        }
      ) do
        jsr223_postprocessor name: 'Clear site selection page title var', script: 'vars.remove("site_selection_page_title")', language: 'groovy'
      end
    end

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

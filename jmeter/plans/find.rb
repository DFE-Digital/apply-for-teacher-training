require 'ruby-jmeter'

BASEURL = ENV.fetch('JMETER_TARGET_BASEURL', 'http://localhost:3002')
WAIT_FACTOR = ENV.fetch('JMETER_WAIT_FACTOR', 1).to_f
THREAD_COUNT = ENV.fetch('JMETER_THREAD_COUNT', 200)
RAMPUP = ENV.fetch('JMETER_RAMPUP', 0).to_i

def url(path)
  BASEURL + path
end

def submit!(name, path, params, &block)
  submit(name: name, url: url(path), fill_in: params, 'DO_MULTIPART_POST': 'true', &block)
end

test do
  cookies clear_each_iteration: true
  view_results_tree
  thread_count = THREAD_COUNT
  random_timer 1000, 2000 * WAIT_FACTOR
  csv_data_set_config filename: 'jmeter-find-params.csv'

  threads count: thread_count, rampup: RAMPUP, continue_forever: true, duration: 3600 do
    visit name: 'Start page', url: url('/') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Start page - search by postcode',
      '/results/filter/location',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'prev_l': 'none',
        'prev_loc': 'none',
        'prev_lng': 'none',
        'prev_lat': 'none',
        'prev_rad': 'none',
        'prev_query': 'none',
        'prev_lq': 'none',
        'l': '${L}',
        'lq': '${LQ}',
        'query': '${QUERY}'
      }
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Subject page - select Primary (after postcode choice)',
      '/results/filter/subject',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'c': '${C}',
        'l': '${L}',
        'lat': '${LAT}',
        'lng': '${LNG}',
        'loc': '${LOC}',
        'lq': '${LQ}',
        'rad': '${RAD}',
        'sortby': '${SORT_BY}',
        'subject_codes[]': '${SUBJECT_CODES}'

      },
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
      extract name: 'course_page', regex: 'data-qa="course__link" class="govuk-link" href="(.+)"'
    end

    visit name: 'Course page, via postcode search', url: url('/${course_page}')

    visit name: 'Start page', url: url('/') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Start page - search across England',
      '/results/filter/location',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'prev_l': 'none',
        'prev_loc': 'none',
        'prev_lng': 'none',
        'prev_lat': 'none',
        'prev_rad': 'none',
        'prev_query': 'none',
        'prev_lq': 'none',
        'lq': '${LQ}',
        'l': '${L}',
        'query': '${QUERY}'
      }
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Subject page - select Primary with English (after across England choice)',
      '/results/filter/subject',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'l': '${L}',
        'subject_codes[]': '${SUBJECT_CODES}'
      }
    ) do
      extract name: 'course_page', regex: 'data-qa="course__link" class="govuk-link" href="(.+)"'
    end

    visit name: 'Course page, via England search', url: url('/${course_page}')

    visit name: 'Start page', url: url('/') do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Start page - search for provider Gorse SCITT',
      '/results/filter/location',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'prev_l': 'none',
        'prev_loc': 'none',
        'prev_lng': 'none',
        'prev_lat': 'none',
        'prev_rad': 'none',
        'prev_query': 'none',
        'prev_lq': 'none',
        'lq': '${LQ}',
        'l': '${L}',
        'query': '${QUERY}'
      }
    ) do
      extract name: 'course_page', regex: 'data-qa="course__link" class="govuk-link" href="(.+)"'
    end

    visit name: 'Course page, via provider search', url: url('/${course_page}')
  end
end.jmx

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
        'l': '1',
        'lq': 'M1+2WD',
        'query': ''
      }
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Subject page - select Primary',
      '/results/filter/subject',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'c': 'England',
        'l': '1',
        'lat': '53.4787275',
        'lng': '-2.2290767',
        'loc': 'Store+St,+Manchester+M1+2WD,+UK',
        'lq': 'M1+2WD',
        'rad': '50',
        'sortby': '2',
        'subjects[]': '00'
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
        'lq': '',
        'l': '2',
        'query': ''
      }
    ) do
      extract name: 'authenticity_token', regex: 'name="authenticity_token" value="(.+?)"'
    end

    submit!(
      'Subject page - select Primary with English',
      '/results/filter/subject',
      {
        'utf8': '✓',
        'authenticity_token' => '${authenticity_token}',
        'l': '2',
        'subjects[]': '01'
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
        'lq': '',
        'l': '3',
        'query': 'gorse scitt'
      }
    ) do
      extract name: 'course_page', regex: 'data-qa="course__link" class="govuk-link" href="(.+)"'
    end

    visit name: 'Course page, via provider search', url: url('/${course_page}')
  end
end.jmx

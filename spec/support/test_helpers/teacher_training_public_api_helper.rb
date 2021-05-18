module TeacherTrainingPublicAPIHelper
  def stub_teacher_training_api_providers(recruitment_cycle_year: RecruitmentCycle.current_year, specified_attributes: [], filter_option: nil)
    scope = stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: 1, per_page: 500 } },
    )

    scope = scope.with(query: filter_option) if filter_option

    scope.to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: build_response_body('provider_list_response.json', specified_attributes),
    )
  end

  def stub_teacher_training_api_providers_with_multiple_pages(recruitment_cycle_year: RecruitmentCycle.current_year)
    [1, 2, 3].each do |page_number|
      stub_pagination_request(recruitment_cycle_year, page_number, paginated_response(page_number))
    end
  end

  def stub_teacher_training_api_provider(provider_code:, recruitment_cycle_year: RecruitmentCycle.current_year, specified_attributes: [], filter_option: nil)
    response_body = build_response_body('single_provider_response.json', specified_attributes)

    stub_teacher_training_single_api_request(
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}",
      response_body,
      filter_option: filter_option,
    )
  end

  def stub_teacher_training_api_course_with_site(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, course_code:, site_code:, vacancy_status: 'full_time_vacancies', course_attributes: [], site_attributes: [])
    course_attributes = course_attributes.any? ? [course_attributes.first.merge(code: course_code)] : [{ code: course_code }]
    site_attributes = site_attributes.any? ? [site_attributes.first.merge(code: site_code)] : [{ code: site_code }]
    stub_teacher_training_api_courses(recruitment_cycle_year: recruitment_cycle_year, provider_code: provider_code, specified_attributes: course_attributes)
    stub_teacher_training_api_sites(recruitment_cycle_year: recruitment_cycle_year, provider_code: provider_code, course_code: course_code, specified_attributes: site_attributes, vacancy_status: vacancy_status)
  end

  def stub_teacher_training_api_course(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, course_code:, specified_attributes: [])
    response_body = build_response_body('course_single_response.json', specified_attributes.merge(code: course_code))
    stub_teacher_training_single_api_request("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses/#{course_code}", response_body)
  end

  def stub_teacher_training_api_courses(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, specified_attributes: [])
    response_body = build_response_body('course_list_response.json', specified_attributes)
    stub_teacher_training_list_api_request("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses", response_body)
  end

  def stub_teacher_training_api_sites(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, course_code:, specified_attributes: [], vacancy_status: 'full_time_vacancies')
    fixture_file = site_fixture(vacancy_status)
    response_body = build_response_body(fixture_file, specified_attributes)
    stub_teacher_training_list_api_request("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses/#{course_code}/locations?include=location_status", response_body)
  end

  def stub_teacher_training_api_subjects(subjects)
    url = "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}subjects"
    response = build_response_body('subject_list_response.json', subjects)

    stub_teacher_training_list_api_request(url, response)
  end

  def stub_teacher_training_api_course_404(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, course_code:)
    stub_404("#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses/#{course_code}")
  end

  def fake_api_provider(provider_attributes = {})
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/single_provider_response.json'),
      ),
      symbolize_names: true,
    )

    api_response[:data][:attributes] = api_response[:data][:attributes].merge(provider_attributes)

    TeacherTrainingPublicAPI::Provider.new(api_response[:data][:attributes])
  end

  def stubbed_recruitment_cycle_year
    @stubbed_recruitment_cycle_year || 2021
  end

private

  def stub_teacher_training_single_api_request(url, response_body, filter_option: nil)
    scope = stub_request(
      :get,
      url,
    )

    scope = scope.with(query: filter_option) if filter_option

    scope.to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: response_body,
    )
  end

  def stub_teacher_training_list_api_request(url, response_body)
    scope = stub_request(
      :get,
      url,
    ).with(
      query: { page: { per_page: 500 } },
    )

    scope.to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: response_body,
    )
  end

  def build_response_body(fixture_file, specified_attributes = [])
    api_response = JSON.parse(
      File.read(
        Rails.root.join("spec/examples/teacher_training_api/#{fixture_file}"),
      ),
      symbolize_names: true,
    )

    if specified_attributes.present?
      record_or_array = api_response[:data]

      new_data = if record_or_array.is_a? Array
                   example_resource = api_response[:data].first
                   specified_attributes.map do |attrs|
                     specified_resource = example_resource.dup
                     specified_resource[:attributes] = specified_resource[:attributes].deep_merge(attrs)
                     specified_resource
                   end
                 else
                   example_resource = api_response[:data]
                   specified_resource = example_resource.dup
                   specified_resource[:attributes] = specified_resource[:attributes].deep_merge(specified_attributes)
                   specified_resource
                 end

      api_response[:data] = new_data
    end

    api_response.to_json
  end

  def paginated_response(page_number)
    JSON.parse(
      File.read(
        Rails.root.join("spec/examples/teacher_training_api/provider_pagination_response_page_#{page_number}.json"),
      ),
      symbolize_names: true,
    )
  end

  def stub_pagination_request(recruitment_cycle_year, page_number, api_response)
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: page_number, per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: api_response.to_json,
    )
  end

  def stub_404(url)
    stub_request(
      :get, url
    ).to_return(
      status: 404,
    )
  end

  def site_fixture(vacancy_status)
    case vacancy_status
    when 'full_time_vacancies'
      'site_list_response_with_full_time_vacancies.json'
    when 'part_time_vacancies'
      'site_list_response_with_part_time_vacancies.json'
    when 'both_full_time_and_part_time_vacancies'
      'site_list_response_with_full_time_and_part_time_vacancies.json'
    end
  end
end

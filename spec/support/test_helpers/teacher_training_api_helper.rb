module TeacherTrainingAPIHelper
  def stub_teacher_training_api_providers(recruitment_cycle_year: RecruitmentCycle.current_year, specified_attributes: [])
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: 1, per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: provider_list_response(specified_attributes).to_json,
    )

    # Fake the error the API sends on exceeding the pagination limit
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers",
    ).with(
      query: { page: { page: 2, per_page: 500 } },
    ).to_return(
      status: 400,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: pagination_error_response,
    )
  end

  def stub_teacher_training_api_courses(recruitment_cycle_year: RecruitmentCycle.current_year, provider_code:, specified_attributes: [])
    stub_request(
      :get,
      "#{ENV.fetch('TEACHER_TRAINING_API_BASE_URL')}recruitment_cycles/#{recruitment_cycle_year}/providers/#{provider_code}/courses",
    ).with(
      query: { page: { per_page: 500 } },
    ).to_return(
      status: 200,
      headers: { 'Content-Type': 'application/vnd.api+json' },
      body: course_list_response(specified_attributes).to_json,
    )
  end

  def fake_api_provider(provider_attributes = {})
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/single_provider_response.json'),
      ),
      symbolize_names: true,
    )

    api_response[:data][:attributes] = api_response[:data][:attributes].merge(provider_attributes)

    TeacherTrainingAPI::Provider.new(api_response[:data][:attributes])
  end

private

  def course_list_response(course_attributes = [])
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/course_list_response.json'),
      ),
      symbolize_names: true,
    )

    if course_attributes
      example_course = api_response[:data].first
      new_data = course_attributes.map do |attrs|
        specified_course = example_course.dup
        specified_course[:attributes] = specified_course[:attributes].deep_merge(attrs)
        specified_course
      end

      api_response[:data] = new_data
    end

    api_response
  end

  def provider_list_response(provider_attributes = [])
    api_response = JSON.parse(
      File.read(
        Rails.root.join('spec/examples/teacher_training_api/provider_list_response.json'),
      ),
      symbolize_names: true,
    )

    if provider_attributes
      example_provider = api_response[:data].first
      new_data = provider_attributes.map do |attrs|
        specified_provider = example_provider.dup
        specified_provider[:attributes] = specified_provider[:attributes].deep_merge(attrs)
        specified_provider
      end

      api_response[:data] = new_data
    end

    api_response
  end

  def pagination_error_response
    File.read(
      Rails.root.join('spec/examples/teacher_training_api/pagination_error.json'),
    )
  end
end

RSpec.shared_examples 'a candidate API endpoint' do |path, _date_param, api_version|
  it 'does not allow access to the API from other data users' do
    api_token = ServiceAPIUser.test_data_user.create_magic_link_token!
    get_api_request "#{path}?updated_since=#{CGI.escape(1.month.ago.iso8601)}", token: api_token
    expect(response).to have_http_status(:unauthorized)
    expect(parsed_response).to be_valid_against_openapi_schema('UnauthorizedResponse', api_version)
  end

  it 'allows access to the API for Candidate users' do
    get_api_request "#{path}?updated_since=#{CGI.escape(1.month.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:success)
  end

  it 'conforms to the API spec' do
    candidate = create(:candidate)
    create(:completed_application_form, candidate:)

    get_api_request "#{path}?updated_since=#{CGI.escape(1.month.ago.iso8601)}", token: candidate_api_token

    expect(parsed_response).to be_valid_against_openapi_schema('CandidateList', api_version)
  end

  it 'returns an error if the `updated_since` parameter is missing' do
    get_api_request path, token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql('param is missing or the value is empty: updated_since')
    expect(parsed_response).to be_valid_against_openapi_schema('ParameterMissingResponse', api_version)
  end

  it 'returns applications filtered with `updated_since`' do
    travel_temporarily_to(2.days.ago) do
      candidate = create(:candidate)
      create(:completed_application_form, candidate:)
    end

    second_candidate = create(:candidate)
    create(:completed_application_form, candidate: second_candidate)

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(1)
  end

  it 'can safely return candidates without an application form who signed up this cycle' do
    create(:candidate)
    create(:completed_application_form)

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(2)
  end

  it 'does not return candidates without application forms which signed up during the previous recruitment_cycle' do
    create(:candidate, created_at: CycleTimetable.apply_deadline(RecruitmentCycle.previous_year))

    get_api_request "#{path}?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(0)
  end

  it 'does not return candidates who only have application forms in the previous cycle' do
    candidate = create(:candidate, created_at: CycleTimetable.apply_deadline(RecruitmentCycle.previous_year))
    create(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.previous_year, candidate:)

    get_api_request "#{path}?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(0)
  end

  it 'returns candidates who have application forms in the current cycle' do
    candidate = create(:candidate, created_at: 1.year.ago)
    create(:completed_application_form, recruitment_cycle_year: RecruitmentCycle.previous_year, candidate:)
    create(:completed_application_form, candidate:)

    get_api_request "#{path}?updated_since=#{CGI.escape(2.years.ago.iso8601)}", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data'].size).to eq(1)
  end

  it 'returns the correct page and the default page items' do
    travel_temporarily_to(2.days.ago) do
      create(:completed_application_form)
    end

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&page=1", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['page-items']).to eq '500'
    expect(response.headers['current-page']).to eq '1'
  end

  it 'navigates through the pages' do
    create_list(:candidate, 4, application_forms: [create(:completed_application_form)])

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&page=1&per_page=2", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['current-page']).to eq '1'

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=2", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['current-page']).to eq '2'
  end

  it 'returns the correct page items from the per_page parameter' do
    travel_temporarily_to(2.days.ago) do
      candidate = create(:candidate)
      create(:completed_application_form, candidate:)
    end

    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&per_page=20", token: candidate_api_token

    expect(response).to have_http_status(:ok)
    expect(response.headers['page-items']).to eq '20'
  end

  it 'returns HTTP status 422 when given a parseable page value that exceeds the range' do
    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&page=2", token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql("expected 'page' parameter to be between 1 and 1, got 2")
    expect(parsed_response).to be_valid_against_openapi_schema('PageParameterInvalidResponse', api_version)
  end

  it 'returns HTTP status 422 when given a parseable per_page value that exceeds the max value' do
    max_value = CandidateAPI::CandidatesController::MAX_PER_PAGE
    get_api_request "#{path}?updated_since=#{CGI.escape(1.day.ago.iso8601)}&page=2&per_page=#{max_value + 1}", token: candidate_api_token

    expect(response).to have_http_status(:unprocessable_entity)
    expect(error_response['message']).to eql("the 'per_page' parameter cannot exceed #{max_value} results per page")
    expect(parsed_response).to be_valid_against_openapi_schema('PerPageParameterInvalidResponse', api_version)
  end
end

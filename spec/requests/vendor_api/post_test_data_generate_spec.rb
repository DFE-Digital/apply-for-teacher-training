require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data/generate', type: :request do
  include VendorApiSpecHelpers

  before do
    FeatureFlag.activate('experimental_api_features')
  end

  it 'generates test data' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/experimental/test-data/generate?count=1'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
  end

  it 'respects the courses_per_application= parameter' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/experimental/test-data/generate?count=1&courses_per_application=2'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(2)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[awaiting_provider_decision])
  end

  it 'does not generate more than three application_choices per application' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/experimental/test-data/generate?count=1&courses_per_application=99'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(3)
  end

  it 'returns responses conforming to the schema' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/experimental/test-data/generate?count=1'

    expect(parsed_response).to be_valid_against_openapi_schema('TestDataGeneratedResponse')
  end

  it 'returns error responses on invalid input' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/experimental/test-data/generate?count=1&courses_per_application=2'

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end
end

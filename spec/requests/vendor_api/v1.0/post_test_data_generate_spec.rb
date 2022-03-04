require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data/generate', type: :request, sidekiq: true do
  include VendorAPISpecHelpers

  it 'generates test data' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
  end

  it 'respects the courses_per_application= parameter' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=2'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(2)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[awaiting_provider_decision])
  end

  it 'does not generate more than three application_choices per application' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=99'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(3)
  end

  it 'generates applications only to courses that the provider ratifies when for_training_courses=true' do
    create(:course_option, course: create(:course, :open_on_apply, accredited_provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=1&for_training_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.all.map(&:course_option).uniq).to contain_exactly(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_ratified_courses=true' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :open_on_apply, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=1&for_ratified_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.all.map(&:course_option).uniq).to contain_exactly(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_test_provider_courses=true' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open_on_apply, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&for_test_provider_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.all.map(&:course_option).map(&:provider).map(&:code).compact).to contain_exactly('TEST')
  end

  it 'returns responses conforming to the schema' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1'

    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
  end

  it 'returns error responses on invalid input' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=2'

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns error when you ask for zero courses per application' do
    create(:course_option, course: create(:course, :open_on_apply, provider: currently_authenticated_provider))

    post_api_request '/api/v1/test-data/generate?count=1&courses_per_application=0'

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end
end

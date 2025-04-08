require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.0/test-data/generate', :sidekiq do
  include VendorAPISpecHelpers

  it 'generates test data' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
  end

  it 'generates test data in previous cycle' do
    create(:course_option, course: create(:course, :previous_year, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&previous_cycle=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[pending_conditions])
    expect(ApplicationChoice.joins(:course).where(course: { recruitment_cycle_year: previous_year }).count).to eq(1)
  end

  describe 'next_cycle' do
    it 'generates test data in the next cycle' do
      create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

      post_api_request '/api/v1.0/test-data/generate?count=1&next_cycle=true'

      expect(Candidate.count).to eq(1)
      expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: next_year }).count).to eq(1)
    end

    it 'ignores the previous cycle param' do
      create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

      post_api_request '/api/v1.0/test-data/generate?count=1&next_cycle=true&previous_cycle=false'

      expect(Candidate.count).to eq(1)
      expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: next_year }).count).to eq(1)
      expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: previous_year }).count).to eq(0)
    end
  end

  it 'respects the courses_per_application= parameter' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=2'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(2)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[awaiting_provider_decision])
  end

  it 'does not generate more than three application_choices per application' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=99'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(3)
  end

  it 'generates applications only to courses that the provider ratifies when for_training_courses=true' do
    create(:course_option, course: create(:course, :open, accredited_provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=1&for_training_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.all.map(&:course_option).uniq).to contain_exactly(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_training_courses=true and previous_cycle=true' do
    create(:course_option, course: create(:course, :previous_year, accredited_provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :previous_year, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=1&for_training_courses=true&previous_cycle=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.joins(:course).where(course: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[pending_conditions])
    expect(ApplicationChoice.all.map(&:course_option).uniq).to contain_exactly(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_ratified_courses=true' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :open, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=1&for_ratified_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.last.course_option).to eq(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_ratified_courses=true and previous_cycle=true' do
    create(:course_option, course: create(:course, :previous_year, provider: currently_authenticated_provider))
    expected_option = create(:course_option, course: create(:course, :previous_year, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=1&for_ratified_courses=true&previous_cycle=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.count).to eq(1)
    expect(ApplicationChoice.joins(:course).where(course: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[pending_conditions])
    expect(ApplicationChoice.all.map(&:course_option).uniq).to contain_exactly(expected_option)
  end

  it 'generates applications only to courses that the provider ratifies when for_test_provider_courses=true and previous_cycle=true' do
    create(:course_option, course: create(:course, :previous_year, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :previous_year, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&for_test_provider_courses=true&previous_cycle=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.joins(:course).where(course: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.joins(:application_form).where(application_form: { recruitment_cycle_year: previous_year }).count).to eq(1)
    expect(ApplicationChoice.all.map(&:status).uniq).to eq(%w[pending_conditions])
    expect(ApplicationChoice.all.map(&:course_option).map(&:provider).map(&:code).compact).to contain_exactly('TEST')
  end

  it 'generates applications only to courses that the provider ratifies when for_test_provider_courses=true' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))
    create(:course_option, course: create(:course, :open, accredited_provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&for_test_provider_courses=true'

    expect(Candidate.count).to eq(1)
    expect(ApplicationChoice.all.map(&:course_option).map(&:provider).map(&:code).compact).to contain_exactly('TEST')
  end

  it 'returns responses conforming to the schema' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1'

    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse', '1.0')
  end

  it 'returns error responses on invalid input' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=2'

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse', '1.0')
  end

  it 'returns error when you ask for zero courses per application' do
    create(:course_option, course: create(:course, :open, provider: currently_authenticated_provider))

    post_api_request '/api/v1.0/test-data/generate?count=1&courses_per_application=0'

    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse', '1.0')
  end
end

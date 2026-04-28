require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.0/applications' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it 'returns correct list of mapped API application statuses' do
    expected_statuses = [
      'awaiting_provider_decision',
      'awaiting_provider_decision', # inactive mapped to awaiting_provider_decision
      'awaiting_provider_decision', # interview mapped to awaiting_provider_decision
      'conditions_not_met',
      'declined',
      'offer',
      'offer_deferred',
      'pending_conditions',
      'recruited',
      'rejected', # rejected mapped to offer_withdrawn
      'rejected',
      'withdrawn',
    ]

    # Statuses we expect ot have been created in the test setup
    actual_statuses = %w[
      awaiting_provider_decision
      conditions_not_met
      declined
      inactive
      interviewing
      offer
      offer_deferred
      offer_withdrawn
      pending_conditions
      recruited
      rejected
      withdrawn
    ]

    # The API is not concerned with unsubmitted applications.
    statuses = ApplicationStateChange.states_visible_to_provider - %w[unsubmitted]

    statuses.each do |status|
      create(:application_choice, status, course_option: course_option_for_provider(provider: currently_authenticated_provider))
    end

    # Make sure the test creates the full variety of statuses
    expect(ApplicationChoice.pluck(:status)).to match_array(actual_statuses)

    get_api_request '/api/v1.3/applications', params: { since: 1.year.ago.iso8601 }

    api_response_statuses = response.parsed_body['data'].map { |a| a.dig('attributes', 'status') }
    expect(api_response_statuses).to match_array(expected_statuses)
  end
end

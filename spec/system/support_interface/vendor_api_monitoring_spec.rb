require 'rails_helper'

RSpec.describe 'Vendor API monitoring page', mid_cycle: false do
  include DfESignInHelpers

  scenario 'rendering the page' do
    given_i_am_a_support_user

    and_there_is_a_provider_who_has_not_connected_to_the_api
    and_there_is_a_provider_who_has_not_synced
    and_there_is_a_provider_who_has_not_posted_a_decision
    and_there_is_a_provider_who_has_received_error_responses_from_the_api

    and_i_visit_the_vendor_api_monitoring_page

    then_i_see_the_provider_who_has_not_connected
    and_i_see_the_provider_who_has_not_synced
    and_i_see_the_provider_who_has_not_posted_a_decision
    and_i_see_the_provider_who_has_received_error_responses_from_the_api
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_i_visit_the_vendor_api_monitoring_page
    visit '/support/vendor-api-monitoring'
  end

  def and_there_is_a_provider_who_has_not_connected_to_the_api
    create(:provider, :with_vendor, name: 'Did not connect')
  end

  def and_there_is_a_provider_who_has_not_synced
    provider = create(:provider, :with_vendor, name: 'Did not sync')
    create(:vendor_api_request,
           provider:,
           request_path: '/api/v1/applications',
           request_method: 'GET',
           created_at: 2.days.ago) # we consider the last 24h
  end

  def and_there_is_a_provider_who_has_not_posted_a_decision
    provider = create(:provider, :with_vendor, name: 'Did not post a decision')
    create(:vendor_api_request,
           provider:,
           request_method: 'POST',
           created_at: 8.days.ago) # we consider the last 7 days
  end

  def and_there_is_a_provider_who_has_received_error_responses_from_the_api
    provider = create(:provider, :with_vendor, name: 'Received an error response')
    create(:vendor_api_request,
           provider:,
           status_code: 422)
  end

  def then_i_see_the_provider_who_has_not_connected
    within('[data-qa="not-connected"]') do
      expect(page).to have_content 'Did not connect'
    end
  end

  def and_i_see_the_provider_who_has_not_synced
    within('[data-qa="not-synced"]') do
      expect(page).to have_content 'Did not sync'
    end
  end

  def and_i_see_the_provider_who_has_not_posted_a_decision
    within('[data-qa="not-posted-decision"]') do
      expect(page).to have_content 'Did not post a decision'
    end
  end

  def and_i_see_the_provider_who_has_received_error_responses_from_the_api
    within('[data-qa="received-error-response"]') do
      expect(page).to have_content 'Received an error response'
    end
  end
end

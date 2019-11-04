require 'rails_helper'

RSpec.feature 'See providers' do
  scenario 'User visits providers page' do
    given_providers_are_configured_to_be_synced do
      given_i_am_a_support_user
      when_i_visit_the_providers_page
      and_i_click_the_sync_button
      then_requests_to_find_should_be_made
      and_i_should_see_the_updated_list_of_providers
    end
  end

  def given_i_am_a_support_user
    page.driver.browser.authorize('test', 'test')
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def given_providers_are_configured_to_be_synced
    former_provider_list = Rails.application.config.providers_to_sync
    new_provider_list = { codes: %w[ABC DEF GHI] }

    Rails.application.config.providers_to_sync = new_provider_list
    yield
    Rails.application.config.providers_to_sync = former_provider_list
  end

  def then_i_should_see_the_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).not_to have_content('Gorse SCITT')
    expect(page).not_to have_content('Somerset SCITT Consortium')
  end

  def and_i_click_the_sync_button
    @request_1 = stub_200_from_find('ABC', 'Royal Academy of Dance')
    @request_2 = stub_200_from_find('DEF', 'Gorse SCITT')
    @request_3 = stub_200_from_find('GHI', 'Somerset SCITT Consortium')
    click_button 'Sync Providers from Find'
  end

  def then_requests_to_find_should_be_made
    expect(@request_1).to have_been_made
    expect(@request_2).to have_been_made
    expect(@request_3).to have_been_made
  end

  def and_i_should_see_the_updated_list_of_providers
    expect(page).to have_content('Royal Academy of Dance')
    expect(page).to have_content('Gorse SCITT')
    expect(page).to have_content('Somerset SCITT Consortium')
  end

  def stub_find_api_provider(provider_code)
    stub_request(:get, ENV.fetch('FIND_BASE_URL') +
      'recruitment_cycles/2020' \
      "/providers/#{provider_code}?include=sites,courses.sites")
  end

  def stub_200_from_find(provider_code, name)
    stub_find_api_provider(provider_code)
      .to_return(
        status: 200,
        headers: { 'Content-Type': 'application/vnd.api+json' },
        body: {
          'data': {
            'id': '1',
            'type': 'providers',
            'attributes': {
              'provider_name': name,
            },
            'relationships': {
              'sites': {
                'data': [
                  { 'id': '1', 'type': 'sites' },
                ],
              },
              'courses': {
                'data': [
                  { 'id': '1', 'type': 'courses' },
                ],
              },
            },
          },
          'included': [
            {
              'id': '1',
              'type': 'sites',
              'attributes': {
                'location_name': '-',
                'name': 'Main Site',
              },
            },
            {
              'id': '1',
              'type': 'courses',
              'attributes': {
                'course_code': 'X130',
                'name': 'Primary',
                'level': 'primary',
                'start_date': 'September 2019',
              },
              'relationships': {
                'sites': {
                  'data': [
                    { 'id': '1', 'type': 'sites' },
                  ],
                },
              },
            },
          ],
          'jsonapi': { 'version': '1.0' },
        }.to_json,
      )
  end
end

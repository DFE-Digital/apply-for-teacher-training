require 'rails_helper'

RSpec.describe 'Candidate adds preferences' do
  include CandidateHelper

  let(:provider) { create(:provider) }
  let(:location_preferences) { [home_location, choice_location] }
  let(:home_location) { { within: 10.0, name: 'BN1 1AA' } }
  let(:choice_location) { { within: 10.0, name: 'BN1 2AA' } }
  let(:new_location) { { within: 10.0, name: 'BN1 3AA' } }
  let(:updated_location) { { within: 20.0, name: 'BN1 3AA' } }
  let(:new_locations) { [home_location, choice_location, new_location] }
  let(:updated_locations) { [home_location, choice_location, updated_location] }
  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 3AA', place_id: 'test_id' },
    ]
  end

  before do
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'Candidate opts in to find a candidate with specific locations' do
    given_i_am_signed_in
    and_feature_flag_is_enabled
    given_i_am_on_the_share_details_page

    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_opt_in_page
    when_i_click('Continue')
    then_i_get_an_error('Select whether to make your application details visible to other training providers')

    and_i_opt_in_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_training_locations
    when_i_click('Back')

    then_i_am_redirected_to_opt_in_page
    when_i_click('Continue')
    and_i_click('Continue')
    then_i_get_an_error('Select where you can train')

    and_i_select_specific_locations
    when_i_click('Continue')

    then_i_am_redirected_to_location_preferences(location_preferences)

    when_i_click('Back')
    then_i_am_redirected_to_training_locations

    when_i_click('Continue')
    then_i_am_redirected_to_location_preferences(location_preferences)

    when_i_click('Add another area')
    and_i_input_a_location
    when_i_click('Add area')
    then_i_am_redirected_to_location_preferences(new_locations)

    when_i_click_change_on_the_last_location
    and_i_edit_a_location
    when_i_click('Update training area')
    then_i_am_redirected_to_location_preferences(updated_locations)

    when_i_click('Continue')
    then_i_am_redirected_to_the_dynamic_locations_page

    when_i_click('Back')
    then_i_am_redirected_to_location_preferences(updated_locations)

    when_i_click('Continue')
    and_i_click('Continue')
    then_i_get_an_error('Select if you want to add the locations of courses you apply to')

    when_i_check_dynamic_locations
    when_i_click('Continue')
    then_i_am_redirected_to_review_page

    when_i_click('Back')
    then_i_am_redirected_to_the_dynamic_locations_page
    and_the_dynamic_locations_is_checked

    when_i_click('Continue')
    then_i_am_redirected_to_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_to_application_choices_with_success_message
  end

  scenario 'Candidate opts in to find a candidate for anywhere in England' do
    given_i_am_signed_in
    and_feature_flag_is_enabled
    given_i_am_on_the_share_details_page

    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_opt_in_page
    when_i_click('Continue')
    then_i_get_an_error('Select whether to make your application details visible to other training providers')

    and_i_opt_in_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_training_locations
    when_i_select_anywhere
    and_i_click('Continue')

    then_i_am_redirected_to_review_page_without_locations

    when_i_click('Submit preferences')
    then_i_am_redirected_to_application_choices_with_success_message
  end

  scenario 'Candidate edits radius on a dynamic location with invalid site data' do
    given_i_am_a_candidate_who_has_opted_in_with_a_dynamic_location
    and_i_have_a_location_preference_with_invalid_site_data_from_a_dynamic_location
    and_i_navigate_to_update_my_preferences

    when_i_update_the_radius_only
    then_it_saves_successfully
  end

  scenario 'Candidate opts out of find a candidate' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    visit new_candidate_interface_pool_opt_in_path
    and_i_opt_out_to_find_a_candidate
    when_i_click('Continue')

    then_i_am_redirected_to_application_choices
  end

  scenario 'Candidate opts out of find a candidate and gives a reason' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    visit new_candidate_interface_pool_opt_in_path
    and_i_opt_out_to_find_a_candidate
    and_i_enter_a_reason_with_too_many_words
    when_i_click('Continue')
    then_i_see_an_error

    when_i_enter_a_reason_with_fewer_words
    when_i_click('Continue')

    then_i_am_redirected_to_application_choices
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = create(
      :application_form,
      :completed,
      postcode: home_location[:name],
      candidate: @current_candidate,
    )
    site = create(
      :site,
      postcode: choice_location[:name],
      latitude: 53.4807593,
      longitude: -2.2426305,
      provider:,
    )
    course = create(:course, provider:)
    course_option = create(
      :course_option,
      site:,
      course:,
    )
    @choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application,
      course_option:,
    )
  end

  def given_i_am_a_candidate_who_has_opted_in_with_a_dynamic_location
    given_i_am_signed_in
    given_courses_exist
    and_feature_flag_is_enabled
    given_i_am_on_the_share_details_page

    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_opt_in_page

    when_i_opt_in_to_find_a_candidate
    and_i_click('Continue')
    and_i_select_specific_locations
    and_i_click('Continue')
    then_i_am_redirected_to_location_preferences(location_preferences)

    and_i_click('Continue')
    when_i_check_dynamic_locations
    and_i_click('Continue')
    and_i_click('Submit preferences')
    then_i_am_redirected_to_application_choices_with_success_message
  end

  def and_i_opt_in_to_find_a_candidate
    choose 'Yes'
  end
  alias_method :when_i_opt_in_to_find_a_candidate, :and_i_opt_in_to_find_a_candidate

  def and_i_select_specific_locations
    choose 'In specific locations'
  end

  def when_i_select_anywhere
    choose 'Anywhere in England'
  end

  def and_i_opt_out_to_find_a_candidate
    choose 'No'
  end

  def and_i_enter_a_reason_with_too_many_words
    fill_in(
      'Why do you not want to share your application details with other providers? (Optional)',
      with: Faker::Lorem.sentence(word_count: 201),
    )
  end

  def then_i_see_an_error
    expect(page).to have_content 'There is a problem'
    expect(page.title).to include 'Error:'
    expect(page).to have_content('Reason for not sharing your application details must be 200 words or less').twice
  end

  def when_i_enter_a_reason_with_fewer_words
    fill_in(
      'Why do you not want to share your application details with other providers? (Optional)',
      with: Faker::Lorem.sentence(word_count: 199),
    )
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def and_i_navigate_to_update_my_preferences
    when_i_click('Change your sharing and location settings')
    and_i_click_the_relevant_change_link
    then_i_see_my_location_preferences_page_including_the_dynamic_location
  end

  def then_i_am_redirected_to_location_preferences(location_preferences)
    expect(page).to have_content('Areas you can train in')

    location_preferences.each_with_index do |location, index|
      within ".govuk-table__body .govuk-table__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(location[:name])
        expect(page).to have_content(location[:within])
      end
    end
  end

  def then_i_am_redirected_to_the_dynamic_locations_page
    expect(page).to have_content 'Add the locations of courses you apply to'
    expect(page.title).to include 'Add the locations of courses you apply to'
  end

  def then_i_am_redirected_to_location_preferences_without_locations
    expect(page).to have_content('Areas you can train in')
    expect(page).to have_content('You have no location preferences')
  end

  def then_i_see_my_location_preferences_page
    expect(page).to have_content('Areas you can train in')
    expect(page).to have_content('Training providers will use the locations you enter here to search for candidates near their courses. You should add all locations that you can train in.')
  end

  def then_i_see_my_location_preferences_page_including_the_dynamic_location
    then_i_see_my_location_preferences_page
    within('table.govuk-table') do
      expect(page).to have_text('Gorse SCITT')
    end
  end

  def and_the_distance_is_updated
    then_i_see_my_location_preferences_page
    within('table.govuk-table') do
      expect(page).to have_css('tr.govuk-table__row', text: '40.0 miles')
    end
  end

  def then_i_am_redirected_to_application_choices
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You are not sharing your application details with providers you have not applied to')
  end

  def then_i_am_redirected_to_opt_in
    expect(page).to have_content('Do you want to be invited to apply to similar courses?')

    yes_option = find_by_id('candidate-interface-pool-opt-ins-form-pool-status-opt-in-field')
    expect(yes_option).to be_checked
  end

  def when_i_check_dynamic_locations
    choose 'Yes'
  end

  def then_i_am_redirected_to_review_page
    expect(page).to have_content('Check your application sharing preferences')

    locations = [
      "Within #{home_location[:within]} miles of #{home_location[:name]}",
      "Within #{choice_location[:within]} miles of #{choice_location[:name]} (#{provider.name})",
      "Within #{updated_location[:within]} miles of #{updated_location[:name]}",
    ].join(' ')

    summary_list = [
      {
        label: 'Do you want to be invited to apply to similar courses?',
        value: 'Yes',
      },
      { label: 'Where can you train?',
        value: 'In specific locations' },
      {
        label: 'Areas you can train in',
        value: locations,
      },
      {
        label: 'Add the locations of courses you apply to',
        value: 'Yes',
      },
    ]

    summary_list.each_with_index do |item, index|
      within ".govuk-summary-list__row:nth-of-type(#{index + 1})" do
        expect(page).to have_content(item[:label])
        expect(page).to have_content(item[:value])
      end
    end
  end

  def then_i_am_redirected_to_review_page_without_locations
    expect(page).to have_content('Check your application sharing preferences')
    expect(page).to have_content('Anywhere in England')
  end

  def and_the_dynamic_locations_is_checked
    dynamic_locations = find_by_id('candidate-interface-dynamic-location-preferences-form-dynamic-location-preferences-true-field')
    expect(dynamic_locations).to be_checked
  end

  def then_i_am_redirected_to_application_choices
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def then_i_am_redirected_to_application_choices_with_success_message
    expect(page).to have_current_path(candidate_interface_application_choices_path)
    expect(page).to have_content('You are sharing your application details with providers you have not applied to')
  end

  def then_i_get_an_error(error_message)
    within '.govuk-error-summary' do
      expect(page).to have_content(error_message)
      expect(page).to have_css('.govuk-error-summary__list li', count: 1)
    end
  end

  def when_i_click_remove_location
    first('a', text: 'Remove').click
  end

  def then_i_am_redirected_to_remove_location_page
    expect(page).to have_content('Do you want to remove this location?')
  end

  def when_i_remove_all_locations
    location_preferences.each do
      when_i_click_remove_location
      then_i_am_redirected_to_remove_location_page
      when_i_click('Yes, remove location')
    end
  end

  def and_i_input_a_location
    fill_in('I can travel up to', with: new_location[:within])
    fill_in('from city, town or postcode', with: new_location[:name])
  end

  def and_i_edit_a_location
    fill_in('I can travel up to', with: updated_location[:within])
    fill_in('from city, town or postcode', with: updated_location[:name])
  end

  def and_feature_flag_is_enabled
    FeatureFlag.activate(:candidate_preferences)
  end

  def given_i_am_on_the_share_details_page
    visit candidate_interface_share_details_path

    expect(page).to have_content('Increase your chances of success by sharing your application details')
  end

  def then_i_am_redirected_to_opt_in_page
    expect(page).to have_content('Do you want to make your application details visible to other training providers?')
  end

  def then_i_am_redirected_to_training_locations
    expect(page).to have_content 'Where can you train?'
  end

  def when_i_click_change_on_the_last_location
    all('a', text: 'Change').last.click
  end

  def and_i_have_a_location_preference_with_invalid_site_data_from_a_dynamic_location
    when_i_click('Add application')
    and_i_complete_the_flow_for_adding_a_choice_with_invalid_coordinates
    then_i_am_redirected_to_application_choices
  end

  def and_i_complete_the_flow_for_adding_a_choice_with_invalid_coordinates
    choose 'Yes, I know where I want to apply'
    click_link_or_button('Continue')

    select 'Gorse SCITT (1N1)'
    click_link_or_button('Continue')

    choose 'Mathematics (SEND) (C998)' # site purposely uses invalid coordinates
    click_link_or_button('Continue')

    click_link_or_button('Review application')
    click_link_or_button('Confirm and submit application')
  end

  def and_i_click_the_relevant_change_link
    click_link('Change your preferred locations')
  end

  def when_i_click_on_the_dynamic_location_change_link
    click_link('Change Y6W 7XN')
  end

  def when_i_update_the_radius_only
    when_i_click_on_the_dynamic_location_change_link
    and_i_change_the_distance
    and_i_click('Update training area')
    then_i_see_my_location_preferences_page
  end

  def and_i_change_the_distance
    fill_in 'I can travel up to', with: '40.0'
  end

  def then_it_saves_successfully
    and_the_distance_is_updated
  end
end

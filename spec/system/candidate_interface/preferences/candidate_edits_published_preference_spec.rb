require 'rails_helper'

RSpec.describe 'Candidate edits published preference' do
  after { FeatureFlag.deactivate(:candidate_preferences) }

  scenario 'Candidate edits share preferences' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_preference_review_page

    when_i_click_change_share_preference
    and_i_choose_not_to_share_my_details

    when_i_click('Continue')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
  end

  scenario 'Candidate adds a reason for opting out' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_preference_review_page

    when_i_click_change_share_preference
    and_i_choose_not_to_share_my_details
    and_i_add_a_reason_for_opting_out

    when_i_click('Continue')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
  end

  scenario 'Candidate edits dynamic location preferences' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    then_i_am_redirected_to_preference_review_page

    when_i_navigate_to_dynamic_locations
    and_i_select_no_dynamic_locations

    when_i_click('Continue')
    then_i_am_redirected_to_preference_review_page
    when_i_click('Submit preferences')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
  end

  scenario 'Candidate edits training locations' do
    given_i_am_signed_in
    and_feature_flag_is_enabled

    given_i_am_on_the_application_choices_page
    when_i_click('Change your sharing and location settings')
    and_i_click('Change where you would like to train')
    then_i_am_redirected_to_the_training_locations_page

    when_i_select_anywhere_in_england
    and_i_click('Continue')
    then_i_am_redirected_to_preference_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_on_the_application_choices_page
    and_the_candidate_preference_id_is_changed
    and_there_are_no_location_preferences
  end

  def given_i_am_signed_in
    given_i_am_signed_in_with_one_login
    @application = create(
      :application_form,
      :completed,
      candidate: @current_candidate,
    )
    @choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application,
    )
    @existing_candidate_preference = create(
      :candidate_preference,
      candidate: @current_candidate,
      status: 'published',
      training_locations: 'specific',
      dynamic_location_preferences: true,
    )
    _location_preferences = create(
      :candidate_location_preference,
      candidate_preference: @existing_candidate_preference,
    )
  end

  def and_feature_flag_is_enabled
    FeatureFlag.activate(:candidate_preferences)
  end

  def given_i_am_on_the_application_choices_page
    visit candidate_interface_application_choices_path
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def then_i_am_redirected_to_preference_review_page
    expect(page).to have_content('Check your application sharing preferences')
  end

  def then_i_am_redirected_to_the_training_locations_page
    expect(page).to have_content('Where can you train?')
  end

  def when_i_click_change_share_preference
    click_on 'Change whether you want to share your application details'
  end

  def and_i_choose_not_to_share_my_details
    choose 'No'
  end

  def and_i_add_a_reason_for_opting_out
    fill_in(
      'Why do you not want to share your application details with other providers? (Optional)',
      with: Faker::Lorem.sentence(word_count: 199),
    )
  end

  def then_i_am_redirected_on_the_application_choices_page
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end

  def and_the_candidate_preference_id_is_changed
    @current_candidate.published_preferences.last != @existing_candidate_preference
  end

  def and_there_are_no_location_preferences
    expect(@current_candidate.published_preferences.last.location_preferences).to eq []
  end

  def when_i_navigate_to_dynamic_locations
    click_on 'Change updating your locations when you apply to a new course'
  end

  def when_i_select_anywhere_in_england
    choose 'Anywhere in England'
  end

  def and_i_select_no_dynamic_locations
    choose 'No'
  end
end

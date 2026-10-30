require 'rails_helper'

RSpec.describe 'Candidate edits published preference', :with_cache do
  include DfE::Bigquery::TestHelper

  before do
    stub_bigquery_non_disclosure_trainee_withdrawals_request
    allow(GoogleMapsAPI::Client).to receive(:new).and_return(client)
    allow(client).to receive(:autocomplete).and_return(api_response)
  end

  let(:provider) { create(:provider) }
  let(:client) { instance_double(GoogleMapsAPI::Client) }
  let(:api_response) do
    [
      { name: 'BN1 3AA', place_id: 'test_id' },
    ]
  end

  scenario 'Candidate edits share preferences' do
    given_i_am_signed_in

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    then_i_am_redirected_to_preference_review_page

    when_i_click_change_share_preference
    and_i_choose_not_to_share_my_details

    when_i_click('Continue')
    then_i_am_redirected_on_the_invites_path
    and_the_candidate_preference_pool_status_is_changed
  end

  scenario 'Candidate adds a reason for opting out' do
    given_i_am_signed_in

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    then_i_am_redirected_to_preference_review_page

    when_i_click_change_share_preference
    and_i_choose_not_to_share_my_details
    and_i_add_a_reason_for_opting_out

    when_i_click('Continue')
    then_i_am_redirected_on_the_invites_path
    and_the_candidate_preference_pool_status_is_changed
    and_the_candidate_preference_opt_out_reason_is_changed
  end

  scenario 'Candidate edits dynamic location preferences' do
    given_i_am_signed_in

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    then_i_am_redirected_to_preference_review_page

    when_i_navigate_to_dynamic_locations
    and_i_select_no_dynamic_locations

    when_i_click('Continue')
    then_i_am_redirected_to_preference_review_page
    when_i_click('Submit preferences')
    then_i_am_redirected_to_the_confirmation_page
    and_the_candidate_preference_dynamic_location_preferences_is_changed
  end

  scenario 'Candidate edits training locations' do
    given_i_am_signed_in

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    and_i_click('Change where you would like to train')
    then_i_am_redirected_to_the_training_locations_page

    when_i_select_anywhere_in_england
    and_i_click('Continue')
    then_i_am_redirected_to_preference_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_to_the_confirmation_page
    and_the_candidate_preference_training_locations_is_changed
    and_there_are_no_location_preferences
  end

  scenario 'Candidate edits funding_type' do
    given_i_am_signed_in(funding_type: 'salary')

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    and_i_click('Change whether you would consider fee-funded courses')
    then_i_am_redirected_to_fee_funding_page
    and_the_funding_type_is_checked

    when_i_check_no_only_salary_courses
    and_i_click('Continue')
    then_i_am_redirected_to_preference_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_to_the_confirmation_page
    and_the_candidate_preference_funding_type_is_changed
  end

  scenario 'Candidate edits funding_type without setting it in the first place' do
    given_i_am_signed_in(funding_type: 'salary')
    and_candidate_preference_funding_type_is_nil

    given_i_am_on_the_invites_page
    when_i_click('Change your decision or update your preferences')
    and_i_click('Select whether you would consider fee-funded courses')
    then_i_am_redirected_to_fee_funding_page

    when_i_check_no_only_salary_courses
    and_i_click('Continue')
    then_i_am_redirected_to_preference_review_page

    when_i_click('Submit preferences')
    then_i_am_redirected_to_the_confirmation_page
    and_the_candidate_preference_funding_type_is_changed
  end

private

  def given_i_am_signed_in(funding_type: 'fee')
    given_i_am_signed_in_with_one_login

    @application_form = @current_candidate.current_application
    course = create(:course, provider:, funding_type:)
    @choice = create(
      :application_choice,
      :awaiting_provider_decision,
      application_form: @application_form,
      course_option: create(:course_option, course:),
    )
    @existing_candidate_preference = create(
      :candidate_preference,
      application_form: @application_form,
      status: 'published',
      training_locations: 'specific',
      dynamic_location_preferences: true,
    )
    _location_preferences = create(
      :candidate_location_preference,
      candidate_preference: @existing_candidate_preference,
    )
  end

  def given_i_am_on_the_invites_page
    visit candidate_interface_invites_path
  end

  def when_i_click(button)
    click_link_or_button(button)
  end
  alias_method :and_i_click, :when_i_click

  def then_i_am_redirected_to_preference_review_page
    expect(page).to have_text('Check your application sharing preferences')
  end

  def then_i_am_redirected_to_the_training_locations_page
    expect(page).to have_text('Where can you train?')
  end

  def when_i_click_change_share_preference
    click_on 'Change whether you want to share your application details'
  end

  def and_i_choose_not_to_share_my_details
    choose 'No'
  end

  def and_i_add_a_reason_for_opting_out
    @opt_out_reason = Faker::Lorem.sentence(word_count: 199)
    fill_in(
      'Why do you not want to share your application details with other providers? (Optional)',
      with: @opt_out_reason,
    )
  end

  def then_i_am_redirected_on_the_invites_path
    expect(page).to have_current_path(candidate_interface_invites_path)
  end

  def then_i_am_redirected_to_the_confirmation_page
    expect(page).to have_current_path(show_candidate_interface_pool_opt_ins_path)
  end

  def and_the_candidate_preference_id_is_changed
    expect(@application_form.published_preferences.last).not_to eq(@existing_candidate_preference)
  end

  def and_there_are_no_location_preferences
    expect(@application_form.published_preference.location_preferences).to eq []
  end

  def when_i_navigate_to_dynamic_locations
    click_on 'Change your locations when you apply to a new course'
  end

  def when_i_select_anywhere_in_england
    choose 'Anywhere in England'
  end

  def and_i_select_no_dynamic_locations
    choose 'No'
  end

  def then_i_am_redirected_to_fee_funding_page
    expect(page).to have_text('What funding types are you interested in?')
  end

  def and_the_funding_type_is_checked
    expect(page).to have_field('I am interested in both courses with fees to pay and salaried courses', checked: true)
  end

  def when_i_check_no_only_salary_courses
    choose 'I am only interested in salaried courses or apprenticeships'
  end

  def and_only_interested_in_salary_courses
    @application_form.published_preferences.last.funding_type == 'salary'
  end

  def and_candidate_preference_funding_type_is_nil
    @existing_candidate_preference.update(funding_type: nil)
  end

  def and_the_candidate_preference_pool_status_is_changed
    expect(@application_form.published_preference.pool_status).to eq('opt_out')
  end

  def and_the_candidate_preference_opt_out_reason_is_changed
    expect(@application_form.published_preference.opt_out_reason).to eq(@opt_out_reason)
  end

  def and_the_candidate_preference_dynamic_location_preferences_is_changed
    expect(@application_form.published_preference.dynamic_location_preferences).to be(false)
  end

  def and_the_candidate_preference_training_locations_is_changed
    expect(@application_form.published_preference.training_locations).to eq('anywhere')
  end

  def and_the_candidate_preference_funding_type_is_changed
    expect(@application_form.published_preference.funding_type).to eq('salary')
  end
end

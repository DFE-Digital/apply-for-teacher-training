require 'rails_helper'

RSpec.describe 'Candidate views withdrawal page' do
  include CourseOptionHelpers
  include CandidateHelper

  before do
    FeatureFlag.activate(:use_new_withdrawal_reasons)
    @candidate = create(:candidate)
    @application_form = create(
      :completed_application_form,
      submitted_at: Time.zone.now,
      candidate: @candidate,
    )
  end

  scenario 'Candidate can navigate the page', time: mid_cycle(RecruitmentCycle.current_year) do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on_withdraw
    then_i_see_all_the_expected_elements_on_the_page
    when_i_click_back_to_application
    then_i_see_the_application_choice
  end

  scenario 'Candidate sees error messages if they do not select a reason', time: mid_cycle(RecruitmentCycle.current_year) do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on_withdraw
    and_i_click_continue_without_selecting_an_answer
    then_i_see_an_error_message_telling_me_to_select_an_option

    when_i_select_other_without_providing_details
    and_i_click_continue
    then_i_see_an_error_message_telling_me_to_add_details

    when_i_enter_more_than_256_characters
    and_i_click_continue
    then_i_see_an_error_message_telling_me_to_be_more_concise
  end

private

  def given_i_have_submitted_an_application
    @application_choice = create(
      :application_choice,
      status: 'awaiting_provider_decision',
      application_form: @application_form,
    )
  end

  def and_i_am_signed_in
    login_as(@candidate)
    visit root_path
  end

  def when_i_view_the_application
    click_on 'Your applicatins'
    click_on @application_choice.current_choice.provider.name
  end

  def and_i_click_on_withdraw
    click_on 'withdraw this application'
  end

  def and_i_click_continue_without_selecting_an_answer
    click_on 'Continue'
  end

  def then_i_see_an_error_message_telling_me_to_select_an_option
    expect(page).to have_content('Select a reason for withdrawing this application').twice
  end

  def when_i_select_other_without_providing_details
    select 'Other'
  end

  def then_i_see_an_error_message_telling_me_to_add_details
    expect(page).to have_content('Enter details to explain the reason for withdrawing').twice
  end

  def when_i_enter_more_than_256_characters
    fill_in 'Details', with: 'a' * 257
  end

  def then_i_see_an_error_message_telling_me_to_be_more_concise
    expect(page).to have_content('Explanation must be 256 characters or fewer')
  end

  def then_i_see_all_the_expected_elements_on_the_page
    expect(page).to have_title 'Why are you withdrawing this application?'
    expect(page).to have_content 'Why are you withdrawing this application?'
    primary_reasons.each do |reason|
      expect(page).to have_content reason
    end
    expect(page).to have_css('.govuk-link.app-primary-navigation__link[aria-current=page]', text: 'Your applications')
  end

  def when_i_click_back_to_application
    click_on 'Back to application'
  end

  def then_i_see_the_application_choice
    expect(page).to have_current_path candidate_interface_course_choices_course_review_path(@application_choice), ignore_query: true
    expect(page).to have_text "Your application to #{@application_choice.current_choice.provider.name}"
  end

  def primary_reasons
    [
      'I am going to apply (or have applied) to a different training provider',
      'I am going to change or update my application with this training provider',
      'I plan to apply for teacher training in the future',
      'I do not want to train to teach anymore',
      'Other',
    ]
  end
end

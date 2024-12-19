require 'rails_helper'

RSpec.describe 'Candidate selects primary reasons for withdrawal' do
  include CourseOptionHelpers
  include CandidateHelper

  before do
    FeatureFlag.activate(:new_candidate_withdrawal_reasons)
    @candidate = create(:candidate)
    @application_form = create(
      :completed_application_form,
      submitted_at: Time.zone.now,
      candidate: @candidate,
    )
  end

  scenario 'Candidate can navigate around the page', time: mid_cycle do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on_withdraw
    then_i_see_all_the_expected_elements_on_the_page
    when_i_click_back_to_application
    then_i_see_the_application_choice
  end

  scenario 'Candidate sees error messages if they do not select a reason', time: mid_cycle do
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

  scenario 'Candidate can save other reason and withdrawal' do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on_withdraw
    and_i_select_other
    and_i_add_details
    and_i_click_continue
    then_i_see_the_review_page
    #   TODO: Add tests for back link and change

    when_i_confirm
    then_i_see_the_success_message
    and_my_application_is_withdrawn_with_the_other_reason
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
    click_on 'Your applications'
    click_on @application_choice.current_course_option.provider.name
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
    choose 'Other'
  end
  alias_method :and_i_select_other, :when_i_select_other_without_providing_details

  def and_i_add_details
    fill_in 'Details', with: 'Some details'
  end

  def then_i_see_the_review_page
    expect(page).to have_content 'Are you sure you want to withdraw this application?'
    expect(page).to have_title 'Are you sure you want to withdraw this application?'
    expect(page).to have_content 'Other: Some details'
    expect(page).to have_css('.govuk-link.app-primary-navigation__link[aria-current=page]', text: 'Your applications')
  end

  def when_i_confirm
    click_on 'Yes I’m sure – withdraw this application'
  end

  def then_i_see_the_success_message
    expect(page).to have_content "You have withdrawn your application to #{@application_choice.current_course_option.provider.name}"
  end

  def and_my_application_is_withdrawn_with_the_other_reason
    expect(@application_choice.reload.status).to eq 'withdrawn'
    expect(@application_choice.withdrawal_reasons.count).to eq 1
    expect(@application_choice.withdrawal_reasons.first).to have_attributes(comment: 'Some details', reason: 'other')
  end

  def then_i_see_an_error_message_telling_me_to_add_details
    expect(page).to have_content('Enter details to explain the reason for withdrawing').twice
  end

  def when_i_enter_more_than_256_characters
    fill_in 'Details', with: 'a ' * 201
  end

  def then_i_see_an_error_message_telling_me_to_be_more_concise
    expect(page).to have_content('Details must be 200 words or fewer').twice
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
    expect(page).to have_text "Your application to #{@application_choice.current_course_option.provider.name}"
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

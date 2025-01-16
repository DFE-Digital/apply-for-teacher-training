require 'rails_helper'

RSpec.describe 'Candidate selects level-one reasons for withdrawal' do
  include CandidateHelper
  include WithdrawalReasonsTestHelpers

  before do
    @candidate = create(:candidate)
    @application_form = create(:completed_application_form, submitted_at: Time.zone.now, candidate: @candidate)
  end

  scenario 'Candidate can navigate around the page', time: mid_cycle do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on('withdraw this application')
    then_i_see_all_the_expected_elements_on_the_page
    when_i_click_on('Back to application')
    then_i_see_the_application_choice

    when_i_click_on('withdraw this application')
    and_i_select_other
    and_i_add_details
    and_i_click_on('Continue', 'Change reason for withdrawal')
    then_i_am_on_the_level_one_reason_select_edit_page
    when_i_click_on('Continue', 'Back')
    then_i_am_on_the_level_one_reason_select_edit_page
    when_i_click_on('Continue', 'Cancel')
    then_i_see_my_application_choices
  end

  scenario 'Candidate sees error messages if they do not select a reason', time: mid_cycle do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on('withdraw this application', 'Continue')
    then_i_see_an_error_message_telling_me_to_select_an_option

    when_i_select_other
    and_i_click_on('Continue')
    then_i_see_an_error_message_telling_me_to_add_details

    when_i_enter_more_than_256_characters
    and_i_click_on('Continue')
    then_i_see_an_error_message_telling_me_to_be_more_concise
  end

  scenario 'Candidate can save other reason and withdrawal' do
    given_i_have_submitted_an_application
    and_i_am_signed_in
    when_i_view_the_application
    and_i_click_on('withdraw this application')
    and_i_select_other
    and_i_add_details
    and_i_click_on('Continue')
    then_i_see_the_review_page
    when_i_click_on('Yes I’m sure – withdraw this application')
    then_i_see_the_success_message
    and_my_application_is_withdrawn_with_the_other_reason
  end

private

  def then_i_am_on_the_level_one_reason_select_edit_page
    withdrawal_reason = @application_choice.withdrawal_reasons.last
    expect(page).to have_current_path(candidate_interface_withdrawal_reasons_level_one_reason_edit_path(@application_choice, withdrawal_reason), ignore_query: true)
    expect(page.find_field('Other')).to be_checked
    expect(find_field('Details').value).to eq 'Some details'
  end

  def then_i_see_an_error_message_telling_me_to_select_an_option
    expect(page).to have_content('Select a reason for withdrawing this application').twice
  end

  def when_i_select_other
    choose 'Other'
  end
  alias_method :and_i_select_other, :when_i_select_other

  def and_i_add_details
    fill_in 'Details', with: 'Some details'
  end

  def then_i_see_the_review_page
    expect(page).to have_content 'Are you sure you want to withdraw this application?'
    expect(page).to have_title 'Are you sure you want to withdraw this application?'
    expect(page).to have_content 'Other: Some details'
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your applications')
  end

  def and_my_application_is_withdrawn_with_the_other_reason
    expect(@application_choice.reload.status).to eq 'withdrawn'
    expect(@application_choice.withdrawal_reasons.count).to eq 1
    expect(
      @application_choice.withdrawal_reasons.first,
    ).to have_attributes(comment: 'Some details', reason: 'other', status: 'published')
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
    level_one_reasons.each { |reason| expect(page).to have_content reason }
    expect(page).to have_css('.govuk-service-navigation__link', text: 'Your applications')
  end

  def then_i_see_the_application_choice
    expect(page).to have_current_path(candidate_interface_course_choices_course_review_path(@application_choice))
    expect(page).to have_text("Your application to #{@application_choice.current_course_option.provider.name}")
  end

  def then_i_see_my_application_choices
    expect(page).to have_current_path(candidate_interface_application_choices_path)
  end
end

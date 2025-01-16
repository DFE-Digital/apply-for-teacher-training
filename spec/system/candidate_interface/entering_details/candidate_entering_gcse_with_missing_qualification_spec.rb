require 'rails_helper'

RSpec.describe 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_maths_gcse_link
    and_i_select_i_do_not_have_yet
    and_i_click_save_and_continue
    then_i_see_the_not_yet_page

    when_i_select_i_am_not
    and_i_click_save_and_continue
    then_i_see_the_equivalency_page

    when_i_enter_the_missing_explanation
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_change_if_i_am_currently_studying
    and_i_select_yes

    when_i_provide_invalid_details
    and_i_click_save_and_continue
    then_i_see_the_error_message

    and_i_provide_my_details
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_the_updated_details
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'English GCSE or equivalent'
  end

  def and_i_select_i_do_not_have_yet
    choose 'I do not have a qualification in English yet'
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_the_not_yet_page
    expect(page).to have_content 'Are you currently studying for a GCSE in English, or equivalent?'
  end

  def when_i_select_i_am_not
    choose 'No'
  end

  def then_i_see_the_equivalency_page
    expect(page).to have_content 'You need a GCSE in English at grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_error_message
    expect(page).to have_content 'There is a problem'
    expect(page).to have_content('Qualification details must be 256 characters or fewer').twice
  end

  def when_i_enter_the_missing_explanation
    fill_in 'candidate-interface-gcse-missing-form-missing-explanation-field', with: 'I’ve completed a course'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'What type of English qualification do you have?'
    expect(page).to have_content 'I don’t have a English qualification yet'
    expect(page).to have_content 'Other evidence I have the skills required (optional)'
    expect(page).to have_content 'I’ve completed a course'
    expect(page).to have_content 'Are you currently studying for this qualification'
    expect(page).to have_content 'No'
  end

  def when_i_change_if_i_am_currently_studying
    all('a', text: 'Change')[1].click
  end

  def and_i_select_yes
    choose 'Yes'
  end

  def and_i_provide_my_details
    fill_in 'Details of the qualification you are studying for', with: 'This is in progress'
  end

  def when_i_provide_invalid_details
    too_long = 'Not completed ' * 19
    fill_in 'Details of the qualification you are studying for', with: too_long
  end

  def then_i_see_the_review_page_with_the_updated_details
    expect(page).to have_content 'What type of English qualification do you have?'
    expect(page).to have_content 'I don’t have a English qualification yet'
    expect(page).to have_content 'Are you currently studying for this qualification'
    expect(page).to have_content 'This is in progress'
    expect(page).to have_no_content 'Other evidence I have the skills required (optional)'
  end
end

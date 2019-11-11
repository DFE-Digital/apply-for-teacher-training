require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in
    and_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_other_uk_qualification_option
    and_i_fill_in_the_type_of_qualification

    and_i_click_save_and_continue

    and_i_visit_the_gcse_review_page

    then_i_see_the_review_page_with_correct_details

    # Sub-scenario: Edit Type of Qualification

    # when_i_click_to_change_qualification_type
    # then_i_see_the_gcse_option_selected
    #
    # when_i_select_a_different_qualification_type
    # and_i_click_save_and_continue
    #
    # and_i_edit_my_details
    # and_i_click_save_and_continue
    #
    # then_i_see_the_review_page_with_updated_details
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def and_i_click_on_the_english_gcse_link
    click_on 'English GCSE or equivalent'
  end

  def when_i_select_other_uk_qualification_option
    choose('Other UK qualification')
  end

  def and_i_fill_in_the_type_of_qualification
    fill_in 'Enter type of qualification', with: 'Scottish Baccalaureate'
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def then_i_see_the_review_for_english_gcse
    expect(page).to have_content 'English GCSE or equivalent'
  end

  def and_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_add_gcse_english_page
    expect(page).to have_content 'Add English GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_edit_details_page
    expect(page).to have_content t('gcse_edit_details.heading.maths')
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'Scottish Baccalaureate'
  end

  def then_i_see_the_review_page_with_updated_details
    expect(page).to have_content 'Scottish Higher'
    expect(page).to have_content 'BB'
    expect(page).to have_content '2000'
  end

  def then_i_see_add_grade_and_year_page
    expect(page).to have_content t('gcse_edit_details.heading.maths')
  end

  def when_i_fill_in_grade_and_year
    fill_in 'Enter your qualification grade', with: 'AA'
    fill_in 'Enter the year you gained your qualification', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def when_i_select_a_different_qualification_type
    choose('Scottish Higher')
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def and_i_edit_my_details
    fill_in 'Enter your qualification grade', with: 'BB'
    fill_in 'Enter the year you gained your qualification', with: '2000'
  end

  def and_i_visit_the_gcse_review_page
    visit '/gcse/maths/review'
  end
end

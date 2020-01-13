require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in
    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_do_not_select_any_gcse_option
    and_i_click_save_and_continue
    then_i_see_the_qualification_type_error

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_page

    when_i_fill_in_the_grade
    and_i_click_save_and_continue
    then_i_see_add_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_correct_details

    when_i_click_to_change_qualification_type
    then_i_see_the_gcse_option_selected

    when_i_select_a_different_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_qualification_type

    when_i_click_to_change_grade
    then_i_see_the_gcse_grade_entered

    when_i_enter_a_different_qualification_grade
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_grade

    when_i_click_to_change_year
    then_i_see_the_gcse_year_entered

    when_i_enter_a_different_qualification_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_updated_year

    when_i_visit_the_candidate_application_page
    i_see_the_maths_gcse_is_completed
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def given_i_am_not_signed_in; end

  def and_i_click_on_the_maths_gcse_link
    click_on 'Maths GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def when_i_select_gce_option
    choose('GCE O Level')
  end

  def and_i_click_save_and_continue
    click_button 'Save and continue'
  end

  def when_i_do_not_select_any_gcse_option; end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'AA'
    expect(page).to have_content '1990'
  end

  def then_i_see_the_review_page_with_updated_qualification_type
    expect(page).to have_content 'Scottish National 5'
  end

  def then_i_see_the_review_page_with_updated_grade
    expect(page).to have_content 'BB'
  end

  def then_i_see_the_review_page_with_updated_year
    expect(page).to have_content '2000'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_titles.maths')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_titles.maths')
  end

  def when_i_fill_in_the_grade
    fill_in 'Please specify your grade', with: 'AA'
  end

  def when_i_fill_in_the_year
    fill_in 'When did you get your qualification?', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def then_i_see_the_gcse_grade_entered
    expect(page).to have_selector("input[value='AA']")
  end

  def then_i_see_the_gcse_year_entered
    expect(page).to have_selector("input[value='1990']")
  end

  def when_i_select_a_different_qualification_type
    choose('Scottish National 5')
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def when_i_click_to_change_year
    page.all('.govuk-summary-list__actions').to_a.second.click_link 'Change'
  end

  def when_i_click_to_change_grade
    page.all('.govuk-summary-list__actions').to_a.third.click_link 'Change'
  end

  def when_i_enter_a_different_qualification_grade
    fill_in 'Please specify your grade', with: 'BB'
  end

  def when_i_enter_a_different_qualification_year
    fill_in 'When did you get your qualification?', with: '2000'
  end

  def i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end
end

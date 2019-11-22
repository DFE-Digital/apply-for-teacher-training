require 'rails_helper'

RSpec.feature 'Candidate entering GCSE details' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in
    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

    when_i_select_gcse_option
    and_i_click_save_and_continue
    then_i_see_add_grade_and_year_page

    when_i_fill_in_grade_and_year
    and_i_click_save_and_continue

    then_i_see_the_review_page_with_correct_details

    when_i_click_to_change_qualification_type
    then_i_see_the_gcse_option_selected

    when_i_select_a_different_qualification_type
    and_i_click_save_and_continue

    and_i_edit_my_details
    and_i_click_save_and_continue

    then_i_see_the_review_page_with_updated_details

    when_i_visit_the_candidate_application_page
    i_see_the_maths_gcse_is_completed
  end

  scenario 'Candidate does not provide a qualification level' do
    given_i_am_signed_in
    when_i_visit_the_candidate_application_page
    and_i_click_on_the_maths_gcse_link

    then_i_see_the_add_gcse_maths_page

    and_i_do_not_select_any_gcse_option

    and_i_click_save_and_continue

    then_i_see_the_qualification_type_error
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

  def and_i_do_not_select_any_gcse_option; end

  def when_i_visit_the_candidate_application_page
    visit '/candidate/application'
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'Add maths GCSE grade 4 (C) or above, or equivalent'
  end

  def then_i_see_the_edit_details_page
    expect(page).to have_content t('gcse_edit_details.page_titles.maths')
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'AA'
    expect(page).to have_content '1990'
  end

  def then_i_see_the_review_page_with_updated_details
    expect(page).to have_content 'Scottish National 5'
    expect(page).to have_content 'BB'
    expect(page).to have_content '2000'
  end

  def then_i_see_add_grade_and_year_page
    expect(page).to have_content t('gcse_edit_details.page_titles.maths')
  end

  def when_i_fill_in_grade_and_year
    fill_in 'What was your grade?', with: 'AA'
    fill_in 'When did you get your qualification?', with: '1990'
  end

  def then_i_see_the_qualification_type_error
    expect(page).to have_content 'Enter the type of qualification'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def when_i_select_a_different_qualification_type
    choose('Scottish National 5')
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def and_i_edit_my_details
    fill_in 'What was your grade?', with: 'BB'
    fill_in 'When did you get your qualification?', with: '2000'
  end

  def i_see_the_maths_gcse_is_completed
    expect(page).to have_css('#maths-gcse-or-equivalent-badge-id', text: 'Completed')
  end
end

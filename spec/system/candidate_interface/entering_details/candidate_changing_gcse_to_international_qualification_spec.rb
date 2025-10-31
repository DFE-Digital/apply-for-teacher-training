require 'rails_helper'

RSpec.describe 'Candidate changing UK GCSE to international qualification' do
  include CandidateHelper

  scenario 'Candidate submits their maths GCSE details and then update them' do
    given_i_am_signed_in_with_one_login

    and_i_click_on_the_maths_gcse_link
    then_i_see_the_add_gcse_maths_page

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

    when_i_select_an_international_qualification_type
    and_i_click_save_and_continue
    then_i_see_the_select_country_page

    when_i_select_a_country
    and_i_click_save_and_continue
    then_i_see_the_add_enic_reference_page

    when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    and_i_click_save_and_continue
    then_i_see_add_new_grade_page

    when_i_fill_in_a_new_grade
    and_i_click_save_and_continue
    then_i_see_qualification_year_page

    when_i_enter_a_different_qualification_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_new_details
  end

  def and_i_click_on_the_maths_gcse_link
    click_link_or_button 'Maths GCSE or equivalent'
  end

  def when_i_select_gcse_option
    choose('GCSE')
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_see_the_add_gcse_maths_page
    expect(page).to have_content 'What type of qualification in maths do you have?'
  end

  def then_i_see_the_review_page_with_correct_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'GCSE'
    expect(page).to have_content 'A'
    expect(page).to have_content '1990'
  end

  def then_i_see_add_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def then_i_see_add_new_grade_page
    expect(page).to have_content t('gcse_edit_grade.page_title', subject: 'maths', qualification_type: 'qualification')
  end

  def then_i_see_add_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'GCSE')
  end

  def when_i_fill_in_the_grade
    fill_in 'What grade is your maths GCSE?', with: 'A'
  end

  def when_i_fill_in_the_year
    fill_in 'What year was your maths GCSE awarded?', with: '1990'
  end

  def then_i_see_the_gcse_option_selected
    expect(find_field('GCSE')).to be_checked
  end

  def when_i_click_to_change_qualification_type
    find_link('Change', href: candidate_interface_gcse_details_edit_type_path(subject: 'maths')).click
  end

  def when_i_select_an_international_qualification_type
    choose('Qualification from outside the UK')
    within '#candidate-interface-gcse-qualification-type-form-qualification-type-non-uk-conditional' do
      fill_in 'Qualification name', with: 'Baccalauréat Général'
    end
  end

  def then_i_see_the_select_country_page
    expect(page).to have_content t('gcse_edit_institution_country.page_title', subject: 'Maths')
  end

  def when_i_select_a_country
    select 'France'
  end

  def then_i_see_the_add_enic_reference_page
    expect(page).to have_current_path candidate_interface_gcse_details_new_enic_path('maths')
  end

  def when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    choose 'Yes'
    click_link_or_button t('save_and_continue')
    fill_in 'candidate-interface-gcse-enic-form-enic-reference-field', with: '12345'
    choose 'GCSE (grades A* to C or 9 to 4)'
  end

  def when_i_fill_in_a_new_grade
    choose 'Other'
    fill_in 'Grade', with: '100%'
  end

  def then_i_see_qualification_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'maths', qualification_type: 'qualification')
  end

  def when_i_enter_a_different_qualification_year
    fill_in 'What year was your maths qualification awarded?', with: '2000'
  end

  def then_i_see_the_review_page_with_new_details
    expect(page).to have_content 'Maths GCSE or equivalent'

    expect(page).to have_content 'Baccalauréat Général'
    expect(page).to have_content '100%'
    expect(page).to have_content '2000'
  end
end

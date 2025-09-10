require 'rails_helper'

RSpec.describe 'Candidate entering GCSE Science details' do
  include CandidateHelper

  scenario 'Candidate submits their Science GCSE award' do
    given_i_am_signed_in_with_one_login
    and_i_wish_to_apply_to_a_course_that_requires_gcse_science
    and_i_visit_the_site

    and_i_click_on_the_science_gcse_link
    then_i_see_the_add_gcse_science_page

    when_i_select_a_non_uk_qualification
    and_i_click_save_and_continue
    and_i_select_the_country_i_studied_in
    and_i_click_save_and_continue
    then_i_see_the_add_enic_reference_page

    when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    and_i_click_save_and_continue
    then_i_see_the_add_grade_page

    when_i_choose_other
    and_i_fill_in_my_grade
    and_i_click_save_and_continue
    then_i_see_qualification_year_page

    when_i_fill_in_the_year
    and_i_click_save_and_continue
    then_i_see_the_review_page_with_new_details
  end

  def and_i_wish_to_apply_to_a_course_that_requires_gcse_science
    course = create(:course, :open, name: 'Science')
    course_option = create(:course_option, course:)
    current_candidate.current_application.application_choices << create(:application_choice, course_option:)
  end

  def and_i_click_on_the_science_gcse_link
    click_link_or_button 'Science GCSE or equivalent'
  end

  def then_i_see_the_add_gcse_science_page
    expect(page).to have_content 'What type of qualification in science do you have?'
  end

  def when_i_select_a_non_uk_qualification
    choose('Qualification from outside the UK')
    within '#candidate-interface-gcse-qualification-type-form-qualification-type-non-uk-conditional' do
      fill_in 'Qualification name', with: 'Diploma'
    end
  end

  def and_i_click_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_select_the_country_i_studied_in
    select 'Niger'
  end

  def then_i_see_the_add_enic_reference_page
    expect(page).to have_current_path candidate_interface_gcse_details_new_enic_path('science')
  end

  def when_i_fill_in_my_enic_reference_and_choose_an_equivalency
    choose 'Yes'
    click_link_or_button t('save_and_continue')
    fill_in 'candidate-interface-gcse-enic-form-enic-reference-field', with: '12345'
    choose 'GCSE (grades A*-C / 9-4)'
  end

  def then_i_see_the_add_grade_page
    expect(page).to have_current_path candidate_interface_new_gcse_science_grade_path
  end

  def when_i_choose_other
    choose 'Other'
  end

  def and_i_fill_in_my_grade
    fill_in 'Grade', with: 'A'
  end

  def when_i_fill_in_the_year
    fill_in 'Year', with: '1990'
  end

  def and_i_visit_the_site
    visit candidate_interface_details_path
  end

  def then_i_see_qualification_year_page
    expect(page).to have_content t('gcse_edit_year.page_title', subject: 'science', qualification_type: 'qualification')
  end

  def then_i_see_the_review_page_with_new_details
    expect(page).to have_content 'Science GCSE or equivalent'

    expect(page).to have_content 'Diploma'
    expect(page).to have_content 'Niger'
    expect(page).to have_content '12345'
    expect(page).to have_content 'GCSE (grades A*-C / 9-4)'
    expect(page).to have_content 'A'
    expect(page).to have_content '1990'
  end
end

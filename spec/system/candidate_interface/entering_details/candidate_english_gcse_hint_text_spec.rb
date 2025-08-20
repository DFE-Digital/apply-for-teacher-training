require 'rails_helper'

RSpec.describe 'English GCSE qualification form hint text' do
  include CandidateHelper

  scenario 'Candidate sees correct hint text for English non-UK qualification' do
    given_i_am_signed_in_with_one_login
    and_i_wish_to_apply_to_a_course_that_requires_gcse_english

    when_i_visit_the_english_gcse_type_page
    then_i_see_the_correct_hint_text_for_english_non_uk_qualification
    and_i_do_not_see_the_old_hint_text_at_the_top
  end

  scenario 'Candidate sees original hint text for Maths non-UK qualification' do
    given_i_am_signed_in_with_one_login
    and_i_wish_to_apply_to_a_course_that_requires_gcse_maths

    when_i_visit_the_maths_gcse_type_page
    then_i_see_the_original_hint_text_for_maths_non_uk_qualification
  end

  private

  def when_i_visit_the_english_gcse_type_page
    visit candidate_interface_gcse_details_edit_type_path(subject: 'english')
  end

  def when_i_visit_the_maths_gcse_type_page
    visit candidate_interface_gcse_details_edit_type_path(subject: 'maths')
  end

  def then_i_see_the_correct_hint_text_for_english_non_uk_qualification
    expect(page).to have_content('For example, High School Diploma, Baccalauréat Général or WASSCE. Do not enter an English as a foreign language assessment here.')
  end

  def then_i_see_the_original_hint_text_for_maths_non_uk_qualification
    expect(page).to have_content('For example, High School Diploma, Higher Secondary School Certificate, Baccalauréat Général, Título de Bachiller')
  end

  def and_i_do_not_see_the_old_hint_text_at_the_top
    expect(page).not_to have_content('This should not be a qualification showing you speak English as a foreign language.')
  end

  def and_i_wish_to_apply_to_a_course_that_requires_gcse_english
    @application_form = create_application_form(candidate: current_candidate)
    @course = build(:course, funding_type: 'fee')
    @course_option = build(:course_option, course: @course)
    create(:application_choice, course_option: @course_option, application_form: @application_form)
  end

  def and_i_wish_to_apply_to_a_course_that_requires_gcse_maths
    @application_form = create_application_form(candidate: current_candidate)
    @course = build(:course, funding_type: 'fee')
    @course_option = build(:course_option, course: @course)
    create(:application_choice, course_option: @course_option, application_form: @application_form)
  end
end
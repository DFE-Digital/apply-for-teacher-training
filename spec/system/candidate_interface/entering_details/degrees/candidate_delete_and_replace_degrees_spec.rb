require 'rails_helper'

RSpec.feature 'Deleting and replacing a degree' do
  include CandidateHelper

  scenario 'Candidate deletes and replaces their degree' do
    given_i_am_signed_in
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_degree
    then_i_see_the_undergraduate_degree_form

    when_i_add_my_degree_back_in
    and_i_mark_the_section_as_incomplete
    and_i_click_on_continue
    then_i_should_see_the_form_and_the_section_is_not_completed
    when_i_click_on_degree
    then_i_can_check_my_undergraduate_degree

    when_i_add_another_degree
    then_i_can_check_my_additional_degree

    when_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
    then_i_can_only_see_my_undergraduate_degree

    when_i_add_another_degree_type_only
    and_i_choose_to_return_later
    then_i_am_returned_to_the_application_form
    and_i_should_see_the_form_and_the_section_is_not_completed
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_view_the_degree_section
    visit candidate_interface_application_form_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def when_i_choose_uk_degree
    choose 'UK degree'
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def when_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def and_i_fill_in_the_degree_type
    fill_in 'Type of degree', with: 'BSc'
  end

  def when_i_fill_in_the_degree_subject
    fill_in 'What subject is your degree?', with: 'Computer Science'
  end

  def when_i_fill_in_the_degree_institution
    fill_in 'Which institution did you study at?', with: 'MIT'
  end

  def when_i_select_the_degree_grade
    choose 'First class honours'
  end

  def when_i_fill_in_the_start_year
    year_with_trailing_space = '2006 '
    fill_in 'Year started course', with: year_with_trailing_space
  end

  def when_i_fill_in_the_graduation_year
    year_with_preceding_space = ' 2009'
    fill_in 'Graduation year', with: year_with_preceding_space
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degrees_review_path
  end

  def when_i_add_another_degree
    click_link t('application_form.degree.another.button')
    expect(page).to have_content(t('page_titles.add_another_degree'))
    choose 'UK degree'
    fill_in 'Type of degree', with: 'Masters'
    and_i_click_on_save_and_continue
    fill_in 'What subject is your degree?', with: 'Maths'
    and_i_click_on_save_and_continue
    fill_in 'Which institution did you study at?', with: 'Thames Valley University'
    and_i_click_on_save_and_continue
    and_i_confirm_i_have_completed_my_degree
    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue
    when_i_fill_in_the_graduation_year
    and_i_click_on_save_and_continue
  end

  def when_i_click_on_continue
    click_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form_and_the_section_is_not_completed
    expect(page).to have_content(t('page_titles.application_form'))
    expect(page).not_to have_css('#degree-badge-id', text: 'Completed')
  end
  alias_method :and_i_should_see_the_form_and_the_section_is_not_completed, :then_i_should_see_the_form_and_the_section_is_not_completed

  def when_i_add_my_degree_back_in
    when_i_choose_uk_degree
    and_i_fill_in_the_degree_type
    and_i_click_on_save_and_continue

    when_i_fill_in_the_degree_subject
    and_i_click_on_save_and_continue

    when_i_fill_in_the_degree_institution
    and_i_click_on_save_and_continue

    and_i_confirm_i_have_completed_my_degree

    when_i_select_the_degree_grade
    and_i_click_on_save_and_continue

    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    when_i_fill_in_the_graduation_year
    and_i_click_on_save_and_continue
  end

  def and_i_submit_the_add_another_degree_form
    click_button t('save_and_continue')
  end

  def then_i_can_check_my_additional_degree
    expect(page).to have_content 'Masters (Hons) Maths'
  end

  def and_i_click_on_delete_degree
    click_link(t('application_form.degree.delete'), match: :first)
  end

  def when_i_click_on_delete_degree
    and_i_click_on_delete_degree
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_button t('application_form.degree.confirm_delete')
  end

  def and_i_confirm_that_i_want_to_delete_my_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
  end

  def then_i_can_only_see_my_undergraduate_degree
    then_i_can_check_my_undergraduate_degree
    expect(page).not_to have_content 'Masters Maths'
  end

  def then_i_can_check_my_revised_undergraduate_degree_type
    expect(page).to have_content 'BA'
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_should_see_the_form
    expect(page).to have_content(t('page_titles.application_form'))
  end

  def then_i_am_told_i_need_to_add_a_degree_to_complete_the_section
    expect(page).to have_content 'You cannot mark this section complete without adding a degree.'
  end

  def and_i_confirm_i_have_completed_my_degree
    choose 'Yes'
    and_i_click_on_save_and_continue
  end

  def and_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:application_qualification, level: 'degree', application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def when_i_add_another_degree_type_only
    click_link t('application_form.degree.another.button')
    expect(page).to have_content(t('page_titles.add_another_degree'))
    choose 'UK degree'
    fill_in 'Type of degree', with: 'Masters'
    and_i_click_on_save_and_continue
  end

  def and_i_choose_to_return_later
    visit candidate_interface_degrees_review_path
    and_i_mark_the_section_as_incomplete
    and_i_click_on_continue
  end

  def then_i_am_returned_to_the_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end
end

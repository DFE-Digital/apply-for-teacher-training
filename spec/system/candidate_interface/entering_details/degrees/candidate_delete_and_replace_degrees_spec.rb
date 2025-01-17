require 'rails_helper'

RSpec.describe 'Deleting and replacing a degree' do
  include CandidateHelper

  scenario 'Candidate deletes and replaces their degree' do
    given_i_am_signed_in_with_one_login
    and_i_have_completed_the_degree_section
    when_i_view_the_degree_section
    and_i_click_on_change_country
    and_i_click_the_back_link
    and_i_click_the_back_link
    and_i_click_on_degree
    and_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_degree
    then_i_am_redirected_to_candidate_details_as_degree_no_longer_exists

    when_i_click_on_degree
    and_i_add_my_degree_back_in
    and_i_mark_the_section_as_incomplete
    and_i_click_on_continue
    then_i_see_the_form_and_the_section_is_not_completed
    when_i_click_on_degree
    then_i_can_check_my_undergraduate_degree

    when_i_add_another_degree
    then_i_can_check_my_additional_degree
    and_i_mark_the_section_as_complete
    and_i_click_on_continue

    when_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
    then_i_can_only_see_my_undergraduate_degree
    and_if_there_is_only_a_foundation_degree
    when_i_return_to_the_application_form
    then_the_degree_section_is_incomplete
  end

  def when_i_view_the_degree_section
    visit candidate_interface_details_path
    when_i_click_on_degree
  end

  def when_i_click_on_degree
    click_link_or_button 'Degree'
  end
  alias_method :and_i_click_on_degree, :when_i_click_on_degree

  def and_i_click_on_change_country
    click_change_link('country')
  end

  def and_i_click_the_back_link
    click_link_or_button 'Back'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Degree'
    expect(page).to have_content 'Add a degree'
  end

  def when_i_click_add_degree
    click_link_or_button 'Add a degree'
  end

  def when_i_choose_united_kingdom
    choose 'United Kingdom'
  end

  def when_i_choose_the_level
    choose 'Bachelor'
  end

  def when_i_fill_in_the_subject
    select 'History', from: 'What subject is your degree?'
  end

  def when_i_choose_the_type_of_degree
    choose 'Bachelor of Arts (BA)'
  end

  def when_i_fill_in_the_university
    select 'University of Cambridge', from: 'candidate_interface_degree_wizard[university]'
  end

  def when_i_choose_whether_degree_is_completed
    choose 'Yes'
  end

  def when_i_select_the_grade
    choose 'First-class honours'
  end

  def when_i_fill_in_the_start_year
    fill_in t('page_titles.what_year_did_you_start_your_degree'), with: '2006'
  end

  def when_i_fill_in_the_award_year
    fill_in t('page_titles.what_year_did_you_graduate'), with: '2009'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_check_my_undergraduate_degree
    expect(page).to have_current_path candidate_interface_degree_review_path
  end

  def when_i_add_another_degree
    click_link_or_button t('application_form.degree.another.button')
    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue
    choose 'Doctorate (PhD)'
    and_i_click_on_save_and_continue
    select 'Philosophy', from: 'What subject is your degree?'
    and_i_click_on_save_and_continue
    choose 'Doctor of Philosophy (DPhil)'
    and_i_click_on_save_and_continue
    select 'University of Oxford', from: 'candidate_interface_degree_wizard[university]'
    and_i_click_on_save_and_continue
    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue
    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue
    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue
  end

  def when_i_click_on_continue
    click_link_or_button t('continue')
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def then_i_see_the_form_and_the_section_is_not_completed
    expect(page).to have_content(t('page_titles.application_form'))
    expect(page).to have_no_css('#degree-badge-id', text: 'Completed')
  end

  def and_i_add_my_degree_back_in
    and_i_answer_that_i_have_a_university_degree

    when_i_choose_united_kingdom
    and_i_click_on_save_and_continue

    when_i_choose_the_level
    and_i_click_on_save_and_continue

    when_i_fill_in_the_subject
    and_i_click_on_save_and_continue

    when_i_choose_the_type_of_degree
    and_i_click_on_save_and_continue

    when_i_fill_in_the_university
    and_i_click_on_save_and_continue

    when_i_choose_whether_degree_is_completed
    and_i_click_on_save_and_continue

    when_i_select_the_grade
    and_i_click_on_save_and_continue

    when_i_fill_in_the_start_year
    and_i_click_on_save_and_continue

    when_i_fill_in_the_award_year
    and_i_click_on_save_and_continue
  end

  def and_i_submit_the_add_another_degree_form
    click_link_or_button t('save_and_continue')
  end

  def then_i_can_check_my_additional_degree
    expect(page).to have_content 'Philosophy'
    expect(page).to have_content 'University of Oxford'
  end

  def and_i_click_on_delete_degree
    click_link_or_button(t('application_form.degree.delete'), match: :first)
  end

  def when_i_click_on_delete_degree
    when_i_click_on_degree
    and_i_click_on_delete_degree
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_link_or_button t('application_form.degree.confirm_delete')
  end

  def and_i_confirm_that_i_want_to_delete_my_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree
  end

  def then_i_can_only_see_my_undergraduate_degree
    then_i_can_check_my_undergraduate_degree
    expect(page).to have_no_content 'Philosophy'
    expect(page).to have_no_content 'University of Oxford'
  end

  def and_i_click_on_continue
    when_i_click_on_continue
  end

  def and_i_confirm_i_have_completed_my_degree
    choose 'Yes'
    and_i_click_on_save_and_continue
  end

  def and_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @current_candidate, university_degree: true)
    create(:application_qualification, level: 'degree', application_form: @application_form)
    @application_form.update!(degrees_completed: true)
    @degree_id = @application_form.application_qualifications.first.id
  end

  def and_i_mark_the_section_as_complete
    choose t('application_form.completed_radio')
  end

  def and_if_there_is_only_a_foundation_degree
    click_change_link('qualification')
    choose 'Foundation degree'
    and_i_click_on_save_and_continue
    choose 'Foundation of Arts (FdA)'
    and_i_click_on_save_and_continue
  end

  def when_i_return_to_the_application_form
    visit candidate_interface_details_path
  end

  def then_the_degree_section_is_incomplete
    expect(page).to have_css('#degree-badge-id', text: 'Incomplete')
  end

  def and_when_i_click_back_on_the_browser
    visit candidate_interface_confirm_degree_destroy_path(@degree_id)
  end

  def then_i_am_redirected_to_candidate_details_as_degree_no_longer_exists
    expect(page).to have_current_path(candidate_interface_details_path)
  end
end

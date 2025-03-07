require 'rails_helper'

RSpec.describe 'Candidates academic and other relevant qualifications' do
  include CandidateHelper

  scenario 'Candidate updates and deletes qualifications in a completed academic and other relevant qualifications section' do
    given_i_am_signed_in_with_one_login
    and_i_have_completed_the_other_qualifications_section

    when_i_visit_the_application_page
    then_the_other_qualifications_section_is_marked_as_complete

    when_i_click_the_other_qualifications_link
    and_i_mark_the_section_as_incomplete
    and_i_click_on_save_changes_and_return
    and_i_visit_the_application_page
    then_the_other_qualifications_section_is_marked_as_incomplete

    when_i_click_the_other_qualifications_link
    and_i_click_to_change_my_qualification
    and_i_change_my_qualification_type
    and_i_change_my_qualification_details
    and_i_click_on_save_and_continue
    and_i_mark_the_section_as_complete
    and_i_click_on_save_changes_and_return
    then_the_other_qualifications_section_is_marked_as_complete

    when_i_click_the_other_qualifications_link
    and_click_on_delete_my_additional_qualification
    and_i_confirm_that_i_want_to_delete_my_qualification

    when_i_visit_the_application_page
    then_the_other_qualifications_section_is_marked_as_incomplete
  end

  def and_i_have_completed_the_other_qualifications_section
    @application_form = create(:application_form, candidate: @current_candidate)
    create(:other_qualification, application_form: @application_form)
    @application_form.update!(other_qualifications_completed: true)
  end

  def when_i_visit_the_application_page
    visit candidate_interface_details_path
  end

  def and_i_visit_the_application_page
    when_i_visit_the_application_page
  end

  def then_the_other_qualifications_section_is_marked_as_complete
    expect(page.text).to include 'A levels and other qualifications Completed'
  end

  def when_i_click_the_other_qualifications_link
    click_link_or_button 'A levels and other qualifications'
  end

  def and_visit_my_application_page
    visit candidate_interface_details_path
  end

  def and_i_click_to_change_my_qualification
    click_change_link('qualification')
  end

  def and_i_change_my_qualification_type
    choose 'A level'
    click_link_or_button t('continue')
  end

  def and_i_change_my_qualification_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_click_on_save_and_continue
    click_link_or_button t('save_and_continue')
  end

  def and_i_mark_the_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def and_i_mark_the_section_as_complete
    choose t('application_form.completed_radio')
  end

  def then_the_other_qualifications_section_is_marked_as_incomplete
    expect(page.text).to include 'A levels and other qualifications Incomplete'
  end

  def and_i_click_on_delete_degree
    click_link_or_button(t('application_form.degree.delete'))
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_link_or_button t('application_form.degree.confirm_delete')
  end

  def and_i_click_on_save_changes_and_return
    click_link_or_button t('save_changes_and_return')
  end

  def and_click_on_delete_my_additional_qualification
    click_link_or_button(t('application_form.other_qualification.delete'))
  end

  def and_i_confirm_that_i_want_to_delete_my_qualification
    click_link_or_button t('application_form.other_qualification.confirm_delete')
  end
end

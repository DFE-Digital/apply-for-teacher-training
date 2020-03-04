require 'rails_helper'

RSpec.feature 'Candidate edits their degree section' do
  include CandidateHelper

  scenario 'Candidate updates and deletes a degree after completing the degree section' do
    given_i_am_signed_in
    and_i_have_completed_the_degree_section

    when_i_visit_the_application_page
    then_the_degree_section_should_be_marked_as_complete

    when_i_click_the_degree_link
    and_i_click_to_change_my_undergraduate_degree
    and_i_change_my_undergraduate_degree
    and_i_click_on_save_and_continue

    when_i_visit_the_application_page
    then_the_degree_section_should_be_marked_as_incomplete

    when_i_click_the_degree_link
    and_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_the_degree_section_should_be_marked_as_complete

    when_i_click_the_degree_link
    and_i_click_on_delete_degree
    and_i_confirm_that_i_want_to_delete_my_additional_degree

    when_i_visit_the_application_page
    then_the_degree_section_should_be_marked_as_incomplete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_completed_the_degree_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:degree_qualification, application_form: @application_form)
    @application_form.update!(degrees_completed: true)
  end

  def when_i_visit_the_application_page
    visit candidate_interface_application_form_path
  end

  def then_the_degree_section_should_be_marked_as_complete
    expect(page.text).to include 'Degree Completed'
  end

  def when_i_click_the_degree_link
    click_link 'Degree'
  end

  def and_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_to_change_my_undergraduate_degree
    page.all('.govuk-summary-list__actions').to_a.first.click_link 'Change qualification'
  end

  def and_i_change_my_undergraduate_degree
    fill_in t('application_form.degree.subject.label'), with: 'Wolf'
    fill_in t('application_form.degree.institution_name.label'), with: 'University of Moon Moon'
  end

  def and_i_click_on_save_and_continue
    click_button t('application_form.degree.base.button')
  end

  def then_the_degree_section_should_be_marked_as_incomplete
    expect(page.text).to include 'Degree Incomplete'
  end

  def and_i_click_on_delete_degree
    click_link(t('application_form.degree.delete'))
  end

  def and_i_confirm_that_i_want_to_delete_my_additional_degree
    click_button t('application_form.degree.confirm_delete')
  end

  def and_i_mark_this_section_as_completed
    check t('application_form.degree.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.degree.review.button')
  end
end

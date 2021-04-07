require 'rails_helper'

RSpec.feature 'Candidates academic and other relevant qualifications' do
  include CandidateHelper

  scenario 'Candidate updates and deletes qualificaitons in a completed academic and other relevant qualifications section' do
    given_i_am_signed_in
    and_i_have_completed_the_other_qualifications_section

    when_i_visit_the_application_page
    then_the_other_qualificaitons_section_should_be_marked_as_complete

    when_i_click_the_other_qualifications_link
    and_i_click_to_change_my_qualification
    and_i_change_my_qualification_type
    and_i_change_my_qualification_details
    and_i_click_on_save_and_continue

    when_i_visit_the_application_page
    then_the_other_qualifications_section_should_not_be_marked_as_complete

    when_i_click_the_other_qualifications_link
    and_click_on_delete_my_additional_qualification
    and_i_confirm_that_i_want_to_delete_my_qualification

    when_i_visit_the_application_page
    then_the_other_qualifications_section_should_not_be_marked_as_complete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_completed_the_other_qualifications_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:other_qualification, application_form: @application_form)
    @application_form.update!(other_qualifications_completed: true)
  end

  def when_i_visit_the_application_page
    visit candidate_interface_application_form_path
  end

  def then_the_other_qualificaitons_section_should_be_marked_as_complete
    expect(page.text).to include 'A levels and other qualifications Completed'
  end

  def when_i_click_the_other_qualifications_link
    click_link 'A levels and other qualifications'
  end

  def and_visit_my_application_page
    visit candidate_interface_application_form_path
  end

  def and_i_click_to_change_my_qualification
    click_change_link('qualification')
  end

  def and_i_change_my_qualification_type
    choose 'A level'
    click_button t('continue')
  end

  def and_i_change_my_qualification_details
    fill_in t('application_form.other_qualification.subject.label'), with: 'Believing in the Heart of the Cards'
    fill_in t('application_form.other_qualification.grade.label'), with: 'A'
    fill_in t('application_form.other_qualification.award_year.label'), with: '2015'
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def then_the_other_qualifications_section_should_not_be_marked_as_complete
    expect(page.text).not_to include 'A levels and other qualifications Complete'
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
    click_button t('continue')
  end

  def and_click_on_delete_my_additional_qualification
    click_link(t('application_form.other_qualification.delete'))
  end

  def and_i_confirm_that_i_want_to_delete_my_qualification
    click_button t('application_form.other_qualification.confirm_delete')
  end
end

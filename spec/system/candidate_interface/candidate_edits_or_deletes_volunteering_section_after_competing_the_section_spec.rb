require 'rails_helper'

RSpec.feature 'Candidate edits their volunteering section' do
  include CandidateHelper

  scenario 'Candidate adds or deletes a role after completing the section' do
    given_i_am_signed_in
    and_i_have_completed_the_volunteering_section

    when_i_visit_the_application_page
    then_the_volunteering_section_should_be_marked_as_complete

    when_i_visit_the_review_volunteering_page
    and_i_click_to_change_my_role
    and_i_change_my_role
    and_i_click_on_save_and_continue
    and_visit_my_application_page
    then_the_volunteering_section_should_be_marked_as_incomplete

    when_i_visit_the_review_volunteering_page
    and_i_mark_this_section_as_completed
    and_i_click_on_continue
    then_the_volunteering_section_should_be_marked_as_complete

    when_i_visit_the_review_volunteering_page
    and_i_click_delete_role
    and_i_confirm_i_want_to_delete_the_role
    and_visit_my_application_page
    then_the_volunteering_section_should_be_marked_as_incomplete
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_completed_the_volunteering_section
    @application_form = create(:application_form, candidate: @candidate)
    create(:application_volunteering_experience, application_form: @application_form)
    @application_form.update!(volunteering_completed: true)
  end

  def when_i_visit_the_application_page
    visit candidate_interface_application_form_path
  end

  def then_the_volunteering_section_should_be_marked_as_complete
    expect(page.text).to include 'Unpaid experience and volunteering Completed'
  end

  def when_i_visit_the_review_volunteering_page
    click_link 'Unpaid experience and volunteering'
  end

  def and_i_click_to_change_my_role
    first('.govuk-summary-list__actions').click_link 'Change'
  end

  def and_i_change_my_role
    fill_in t('application_form.volunteering.organisation.label'), with: 'Much Wow School'
  end

  def and_i_click_on_save_and_continue
    click_button t('application_form.volunteering.complete_form_button')
  end

  def then_the_volunteering_section_should_be_marked_as_incomplete
    expect(page.text).to include 'Unpaid experience and volunteering Incomplete'
  end

  def and_i_mark_this_section_as_completed
    check t('application_form.volunteering.review.completed_checkbox')
  end

  def and_i_click_on_continue
    click_button t('application_form.volunteering.review.button')
  end

  def and_visit_my_application_page
    when_i_visit_the_application_page
  end

  def and_i_click_delete_role
    click_link t('application_form.volunteering.delete')
  end

  def and_i_confirm_i_want_to_delete_the_role
    click_button t('application_form.volunteering.confirm_delete')
  end
end

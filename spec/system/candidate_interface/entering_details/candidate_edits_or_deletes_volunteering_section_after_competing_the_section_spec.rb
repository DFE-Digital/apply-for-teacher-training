require 'rails_helper'

RSpec.feature 'Candidate edits their volunteering section' do
  include CandidateHelper

  before do
    FeatureFlag.deactivate('restructured_work_history')
  end

  scenario 'Candidate adds or deletes a role after completing the section' do
    given_i_am_signed_in
    and_i_have_completed_the_volunteering_section

    when_i_visit_the_application_page
    then_the_volunteering_section_should_be_marked_as_complete

    when_i_click_the_volunteering_section_link
    and_i_click_to_change_my_role
    and_i_change_my_role
    and_i_click_on_save_and_continue
    and_visit_my_application_page
    then_the_volunteering_section_should_be_marked_as_complete

    when_i_click_the_volunteering_section_link
    and_i_mark_this_section_as_incomplete
    and_i_click_on_continue
    then_the_volunteering_section_should_be_marked_as_incomplete

    when_i_click_the_volunteering_section_link
    and_i_click_delete_role
    and_i_confirm_i_want_to_delete_the_role
    and_visit_my_application_page
    then_the_volunteering_section_should_be_marked_as_complete

    when_i_click_the_volunteering_section_link
    then_i_should_be_see_the_volunteering_review_page
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
    expect(page.text).to include 'Unpaid experience'
  end

  def when_i_click_the_volunteering_section_link
    click_link 'Unpaid experience'
  end

  def and_i_click_to_change_my_role
    click_change_link('role')
  end

  def and_i_change_my_role
    fill_in t('application_form.volunteering.organisation.label'), with: 'Much Wow School'
  end

  def and_i_click_on_save_and_continue
    click_button t('save_and_continue')
  end

  def then_the_volunteering_section_should_be_marked_as_incomplete
    expect(page.text).to include 'Unpaid experience Incomplete'
  end

  def and_i_mark_this_section_as_incomplete
    choose t('application_form.incomplete_radio')
  end

  def and_i_mark_this_section_as_completed
    choose t('application_form.completed_radio')
  end

  def and_i_click_on_continue
    click_button t('continue')
  end

  def and_visit_my_application_page
    when_i_visit_the_application_page
  end

  def and_i_click_delete_role
    click_link t('application_form.volunteering.delete.action')
  end

  def and_i_confirm_i_want_to_delete_the_role
    click_button t('application_form.volunteering.delete.confirm')
  end

  def then_i_should_be_see_the_volunteering_review_page
    expect(page).to have_current_path(candidate_interface_review_volunteering_path)
  end
end

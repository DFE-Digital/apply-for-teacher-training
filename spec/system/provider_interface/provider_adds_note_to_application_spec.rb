require 'rails_helper'

RSpec.describe 'A Provider viewing an individual application', :with_audited do
  include CourseOptionHelpers
  include DfESignInHelpers

  scenario 'adds a note' do
    given_i_am_a_provider_user_with_dfe_sign_in
    and_my_organisation_has_received_an_application
    and_i_sign_in_to_the_provider_interface

    when_i_visit_that_application_in_the_provider_interface
    and_i_visit_the_notes_tab
    then_i_see_workflow_actions

    when_i_click_to_add_a_note
    and_i_attempt_to_create_a_note_with_no_text
    then_i_see_an_error_message

    when_i_click_back_i_go_to_the_notes_page
    and_i_click_to_add_a_note
    and_i_write_a_note_with_some_text

    then_i_am_still_on_the_notes_tab
    and_the_notes_tab_includes_the_new_note
    and_i_can_navigate_to_the_new_note
    and_the_new_note_also_appears_on_the_timeline
  end

  def given_i_am_a_provider_user_with_dfe_sign_in
    @provider = create(:provider)
    @provider_user = create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
    @provider_user.providers << @provider
    @provider_user.provider_permissions.update_all(make_decisions: true, set_up_interviews: true)
    user_exists_in_dfe_sign_in
  end

  def and_my_organisation_has_received_an_application
    course_option = course_option_for_provider_code(provider_code: @provider.code)
    @application_choice = create(:application_choice, :awaiting_provider_decision, course_option:)
  end

  def when_i_visit_that_application_in_the_provider_interface
    visit provider_interface_application_choice_path(@application_choice)
  end

  def and_i_visit_the_notes_tab
    click_link_or_button 'Notes'
  end

  def then_i_see_workflow_actions
    expect(page).to have_link('Set up interview')
    expect(page).to have_link('Make decision')
  end

  def and_i_click_to_add_a_note
    click_link_or_button 'Add note'
  end

  alias_method :when_i_click_to_add_a_note, :and_i_click_to_add_a_note

  def and_i_attempt_to_create_a_note_with_no_text
    fill_in 'Note', with: ''
    click_link_or_button 'Save note'
  end

  def then_i_see_an_error_message
    within '.govuk-error-summary__list' do
      expect(page).to have_content('Enter a note')
    end
  end

  def when_i_click_back_i_go_to_the_notes_page
    click_link_or_button 'Back'
    expect(page).to have_current_path(provider_interface_application_choice_notes_path(@application_choice))
  end

  def and_i_write_a_note_with_some_text
    @note_text = 'The candidate has not forwarded the required documents yet.'
    fill_in 'Note', with: @note_text
    click_link_or_button 'Save note'
    @note = Note.last
  end

  def then_i_am_still_on_the_notes_tab
    expect(page).to have_current_path(provider_interface_application_choice_notes_path(@application_choice))
  end

  def and_the_notes_tab_includes_the_new_note
    expect(page).to have_link(
      "#{@provider_user.full_name}, #{Time.zone.now.to_fs(:govuk_date_and_time)}",
      href: provider_interface_application_choice_note_path(@application_choice, @note),
    )
    expect(page).to have_content(@note_text)
  end

  def and_i_can_navigate_to_the_new_note
    click_link_or_button "#{@provider_user.full_name}, #{Time.zone.now.to_fs(:govuk_date_and_time)}"

    expect(page).to have_content(@note_text)

    click_link_or_button 'Back'
  end

  def and_the_new_note_also_appears_on_the_timeline
    click_link_or_button 'Timeline'
    expect(page).to have_content('Note added')
  end
end

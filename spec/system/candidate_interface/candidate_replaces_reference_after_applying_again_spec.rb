require 'rails_helper'

RSpec.feature 'Candidate applying again' do
  include CandidateHelper

  scenario 'Can replace a completed reference' do
    # TODO: this feature cannot pass with the flag off at the moment as currently,
    # there is no way to delete a reference in the feedback provided state

    given_the_pilot_is_open
    and_the_decoupled_references_flag_is_off
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application_with_references
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_click_on_start_now
    and_i_am_told_my_new_application_is_ready_to_edit

    when_i_click_go_to_my_application_form
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_cannot_change_referee_details

    when_i_delete_a_referee
    then_i_can_see_i_only_have_one_referee

    when_i_add_a_new_referee
    then_i_can_see_i_have_two_referees
    and_i_can_change_new_referee_details
    and_references_for_original_application_are_not_affected

    when_i_complete_the_section
    and_i_select_a_course
    and_i_submit_my_application
    then_i_am_informed_my_new_referee_will_be_contacted
    and_my_application_is_awaiting_references
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_the_decoupled_references_flag_is_off
    FeatureFlag.deactivate('decoupled_references')
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application_with_references
    @application_form = create(:completed_application_form, candidate: @candidate, with_gcses: true, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
    create(:application_choice, status: :rejected, application_form: @application_form)
    @completed_references = create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @application_form)
    @refused_reference = create(:reference, feedback_status: :feedback_refused, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Do you want to apply again?'
  end

  def and_i_click_on_start_now
    click_on 'Start now'
  end

  def and_i_am_told_my_new_application_is_ready_to_edit
    expect(page).to have_content('Your new application is ready for editing')
  end

  def when_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    click_on 'Referees'
  end

  def then_i_cannot_change_referee_details
    expect(page).not_to have_link('Change')
  end

  def when_i_delete_a_referee
    click_on "Delete referee #{@completed_references[0].name}"
    click_on I18n.t('application_form.referees.sure_delete_entry')
  end

  def then_i_can_see_i_only_have_one_referee
    expect(page).not_to have_content @completed_references[0].name
    expect(page).to have_content @completed_references[1].name
  end

  def when_i_add_a_new_referee
    click_link 'Add another referee'
    choose 'Academic'
    click_button 'Continue'

    candidate_fills_in_referee(
      name: 'Bob Example',
      email: 'bob@example.com',
    )
    click_button 'Save and continue'
  end

  def then_i_can_see_i_have_two_referees
    expect(page).to have_content @completed_references[1].name
    expect(page).to have_content 'Bob Example'
  end

  def and_i_can_change_new_referee_details
    expect(page).to have_link('Change name for Bob Example')
    expect(page).to have_link('Change email address for Bob Example')
  end

  def and_references_for_original_application_are_not_affected
    original_referees = @application_form.reload.application_references
    expect(original_referees.map(&:name)).to match_array([
      @completed_references[0].name,
      @completed_references[1].name,
      @refused_reference.name,
    ])
  end

  def when_i_complete_the_section
    check t('application_form.completed_checkbox')
    click_button t('application_form.continue')
  end

  def and_i_select_a_course
    click_link 'Course choice', exact: true
    given_courses_exist

    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    choose 'Primary (2XT2)'
    click_button 'Continue'

    expect(page).to have_link 'Delete choice'
    expect(page).to have_content 'I have completed this section'
    expect(page).not_to have_button 'Add another course'
  end

  def and_i_submit_my_application
    check t('application_form.courses.complete.completed_checkbox')
    click_button 'Continue'
    @apply_again_application_form = candidate_submits_application
  end

  def then_i_am_informed_my_new_referee_will_be_contacted
    expect(page).to have_content 'We’ve sent an email to your referee'
  end

  def and_my_application_is_awaiting_references
    application_choice = @apply_again_application_form.application_choices.first
    expect(application_choice.status).to eq 'awaiting_references'
  end
end

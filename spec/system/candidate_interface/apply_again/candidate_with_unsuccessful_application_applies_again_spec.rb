require 'rails_helper'

RSpec.feature 'Candidate with unsuccessful application' do
  include CandidateHelper

  scenario 'Can apply again' do
    given_the_pilot_is_open
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_click_on_start_now
    then_i_see_the_before_you_start_page
    and_i_am_told_my_new_application_is_ready_to_edit

    when_i_click_go_to_my_application_form
    and_i_click_on_the_link_to_my_previous_application
    then_i_see_the_review_previous_application_page

    when_i_click_back
    then_i_see_my_current_application_page

    when_i_click_through_to_select_a_course
    then_i_am_informed_i_can_only_select_one_course
    and_i_can_indeed_only_select_one_course

    when_i_complete_my_application
    and_i_skip_feedback
    then_my_application_is_submitted_and_sent_to_the_provider
    and_i_receive_an_email_that_my_application_has_been_sent
    and_i_do_not_see_referee_related_guidance
    and_i_cannot_apply_again_yet
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application
    @application_form = create(
      :completed_application_form,
      :with_gcses,
      :with_completed_references,
      references_count: 2,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    create(:application_choice, status: :rejected, application_form: @application_form)
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

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_see_the_before_you_start_page
    expect(page).to have_current_path candidate_interface_before_you_start_path
  end

  def and_i_am_told_my_new_application_is_ready_to_edit
    expect(page).to have_content('Your new application is ready for editing')
  end

  def when_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def and_i_click_on_the_link_to_my_previous_application
    click_link 'First application'
  end

  def then_i_see_the_review_previous_application_page
    expect(page).to have_current_path(candidate_interface_review_previous_application_path(@application_form.id))
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_see_my_current_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def when_i_click_through_to_select_a_course
    click_link 'Choose your course', exact: true
  end

  def then_i_am_informed_i_can_only_select_one_course
    expect(page).to have_content('You can only apply to 1 course at a time at this stage of your application')
  end

  def and_i_can_indeed_only_select_one_course
    given_courses_exist

    click_link t('continue')
    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')

    expect(page).to have_link 'Delete choice'
    expect(page).to have_content 'I have completed this section'
    expect(page).not_to have_button 'Add another course'
  end

  def when_i_complete_my_application
    check t('application_form.courses.complete.completed_checkbox')
    click_button t('continue')
    candidate_submits_application
  end

  def and_i_skip_feedback
    click_button 'Continue'
  end

  def then_my_application_is_submitted_and_sent_to_the_provider
    expect(page).to have_content 'Application successfully submitted'
    @apply_again_choice = ApplicationForm.last.application_choices.first
    expect(@apply_again_choice.status).to eq 'awaiting_provider_decision'
  end

  def and_i_receive_an_email_that_my_application_has_been_sent
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content t('candidate_mailer.application_submitted.subject')
  end

  def and_i_do_not_see_referee_related_guidance
    expect(page).not_to have_content 'References'
  end

  def and_i_cannot_apply_again_yet
    visit candidate_interface_start_apply_again_path
    and_i_click_on_start_now
    expect(page).to have_current_path candidate_interface_application_complete_path
  end
end

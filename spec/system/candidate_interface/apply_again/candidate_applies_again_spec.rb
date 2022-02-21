require 'rails_helper'

RSpec.feature 'Apply again with three choices' do
  include CandidateHelper

  scenario 'Candidate applies again with three choices' do
    and_i_am_signed_in_as_a_candidate
    when_i_have_an_unsuccessful_application
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    then_i_am_redirected_to_the_new_application_form
    and_i_am_told_my_new_application_is_ready_to_review

    when_i_click_on_the_link_to_my_previous_application
    then_i_see_the_review_previous_application_page

    when_i_click_back
    then_i_see_my_current_application_page

    then_i_should_see_text_suggesting_that_i_can_apply_to_three_courses
    then_i_can_select_a_course
    then_i_should_see_text_suggesting_that_i_can_add_two_more_courses
    and_i_should_be_on_the_review_page
    and_i_add_two_more_courses
    then_i_can_see_my_application_with_three_courses
    and_i_complete_the_section

    when_i_complete_my_application
    and_i_skip_feedback
    then_my_application_is_submitted_and_sent_to_the_provider
    and_i_receive_an_email_that_my_application_has_been_sent
    and_i_do_not_see_referee_related_guidance
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application
    @application_form = create(
      :completed_application_form,
      candidate: @candidate,
      references_completed: true,
    )
    create_list(:selected_reference, 2, application_form: @application_form)
    create(:application_choice, status: :rejected, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def then_i_am_redirected_to_the_new_application_form
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def and_i_am_told_my_new_application_is_ready_to_review
    expect(page).to have_content('We’ve copied your application. Please review all sections.')
  end

  def when_i_click_on_the_link_to_my_previous_application
    click_link 'First application'
  end

  def when_i_click_back
    click_link 'Back'
  end

  def then_i_see_my_current_application_page
    expect(page).to have_current_path(candidate_interface_application_form_path)
  end

  def then_i_see_the_review_previous_application_page
    expect(page).to have_current_path(candidate_interface_review_previous_application_path(@application_form.id))
  end

  def then_i_should_see_text_suggesting_that_i_can_apply_to_three_courses
    expect(page).to have_content('You can apply for up to 3 courses.')
  end

  def and_i_complete_the_section
    choose 'Yes, I have completed this section'
    click_button 'Continue'
  end

  def then_i_can_select_a_course
    click_link 'Choose your courses', exact: true
    given_courses_exist

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')
  end

  def candidate_submits_application
    click_link 'Check and submit your application'
    click_link t('continue')

    # Equality and diversity questions
    click_link t('continue')

    # What is your sex?
    choose 'Prefer not to say'
    click_button t('continue')

    # Are you disabled?
    choose 'Prefer not to say'
    click_button t('continue')

    # What is your ethnic group?
    choose 'Prefer not to say'
    click_button t('continue')

    # Review page
    click_link t('continue')

    # Is there anything else you would like to tell us about your application?
    choose 'No'
    click_button 'Send application'

    @application = ApplicationForm.last
  end

  def when_i_complete_my_application
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

  def then_i_should_see_text_suggesting_that_i_can_add_two_more_courses
    expect(page).to have_content('You can add 2 more courses')
  end

  def and_i_should_be_on_the_review_page
    expect(page).to have_current_path(candidate_interface_course_choices_review_path)
  end

  def and_i_add_two_more_courses
    click_link 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'Drama (2397)'
    click_button t('continue')

    click_link 'Add another course'
    choose 'Yes, I know where I want to apply'
    click_button t('continue')
    select 'Gorse SCITT (1N1)'
    click_button t('continue')
    choose 'English (6Z9H)'
    click_button t('continue')
  end

  def then_i_can_see_my_application_with_three_courses
    expect(page).to have_content('Primary (2XT2)')
    expect(page).to have_content('Drama (2397)')
    expect(page).to have_content('English (6Z9H)')
  end
end

require 'rails_helper'

RSpec.feature 'Apply again with four choices', continuous_applications: false do
  include CandidateHelper

  it 'Candidate applies again with four choices' do
    given_i_am_after_apply_1_deadline
    given_i_am_signed_in_as_a_candidate
    and_the_one_personal_statement_feature_flag_is_active
    and_i_have_an_unsuccessful_application

    when_i_visit_the_application_dashboard
    then_i_should_see_the_apply_again_banner
    and_i_should_see_the_deadline_banner

    when_i_click_on_apply_again
    then_i_am_redirected_to_the_new_application_form
    and_i_am_told_my_new_application_is_ready_to_review

    when_i_click_on_the_link_to_my_previous_application
    then_i_see_the_review_previous_application_page

    when_i_click_back
    then_i_see_my_current_application_page

    then_i_should_see_text_suggesting_that_i_can_apply_to_four_courses
    then_i_can_select_a_course
    then_i_can_see_my_application_with_one_course
    and_i_complete_the_section

    when_i_review_my_references
    and_i_complete_the_section

    when_i_review_and_edit_my_personal_statement
    then_i_see_my_updated_personal_statement
    and_i_complete_the_section

    and_i_complete_my_application
    and_i_skip_feedback

    then_my_application_is_submitted_and_sent_to_the_provider
    and_i_receive_an_email_that_my_application_has_been_sent
    and_i_do_not_see_referee_related_guidance
  end

  def given_i_am_after_apply_1_deadline
    TestSuiteTimeMachine.travel_permanently_to(after_apply_1_deadline(2023) + 1.day)
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_unsuccessful_application
    travel_temporarily_to(before_apply_1_deadline) do
      @application_form = create(
        :completed_application_form,
        :eligible_for_free_school_meals,
        candidate: @candidate,
        references_completed: true,
      )
      create_list(:selected_reference, 2, application_form: @application_form)
      create(:application_choice, status: :rejected, application_form: @application_form)
    end
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_should_see_the_apply_again_banner
    expect(page).to have_content 'If now’s the right time for you, you can still apply for courses that start this academic year.'
    expect(page).to have_link 'teacher training adviser'
    expect(page).to have_link 'respond to these classroom scenarios'
  end

  def and_i_should_see_the_deadline_banner
    year_range = CycleTimetable.cycle_year_range
    deadline_date = CycleTimetable.date(:apply_2_deadline).to_fs(:govuk_date)
    deadline_time = CycleTimetable.date(:apply_2_deadline).to_fs(:govuk_time)

    expect(page).to have_content("The deadline for applying to courses starting in the #{year_range} academic year is #{deadline_time} on #{deadline_date}")
  end

  def when_i_click_on_apply_again
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

  def then_i_should_see_text_suggesting_that_i_can_apply_to_four_courses
    expect(page).to have_content('You can apply for up to 4 courses.')
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

  def when_i_review_my_references
    click_link 'References to be requested if you accept an offer'
  end

  def and_the_one_personal_statement_feature_flag_is_active
    FeatureFlag.activate('one_personal_statement')
  end

  def when_i_review_and_edit_my_personal_statement
    click_link 'Your personal statement'
    click_link 'Edit your answer'
    fill_in 'Your personal statement', with: 'I am a hardworking person'
    click_button t('continue')
  end

  def then_i_see_my_updated_personal_statement
    expect(page).to have_content('I am a hardworking person')
  end

  def and_i_complete_my_application
    candidate_submits_application
  end

  def and_i_skip_feedback
    click_button 'Continue'
  end

  def then_my_application_is_submitted_and_sent_to_the_provider
    expect(page).to have_content('Application submitted')
    @apply_again_choice = ApplicationForm.last.application_choices.first
    expect(@apply_again_choice.status).to eq('awaiting_provider_decision')
  end

  def and_i_receive_an_email_that_my_application_has_been_sent
    open_email(@candidate.email_address)
    expect(current_email.subject).to have_content(t('candidate_mailer.application_submitted.subject'))
  end

  def and_i_do_not_see_referee_related_guidance
    expect(page).not_to have_content('References')
  end

  def then_i_can_see_my_application_with_one_course
    expect(page).to have_content('Primary (2XT2)')
  end
end

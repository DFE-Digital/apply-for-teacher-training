require 'rails_helper'

RSpec.feature 'Manually carry over unsubmitted applications' do
  include CandidateHelper
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(mid_cycle) do
      example.run
    end
  end

  scenario 'Carry over application and remove all application choices when new cycle opens' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_continue
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses

    when_i_add_a_course
    and_i_complete_the_section
    and_i_visit_the_course_choices_section
    then_i_see_the_course_choice_review_page

    when_i_add_another_course
    and_i_complete_the_section
    and_i_receive_references
    and_i_submit_my_application
    then_my_application_is_awaiting_provider_decision
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      :with_gcses,
      submitted_at: nil,
      candidate: @candidate,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    @application_choice = create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @first_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
    @second_reference = create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
  end

  def and_the_recruitment_cycle_ends
    Timecop.safe_mode = false
    Timecop.travel(after_apply_reopens)
  ensure
    Timecop.safe_mode = true
  end

  def and_the_cancel_unsubmitted_applications_worker_runs
    CancelUnsubmittedApplicationsWorker.new.perform
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def then_i_am_redirected_to_the_carry_over_interstitial
    expect(page).to have_current_path candidate_interface_start_carry_over_path
  end

  def when_i_click_on_continue
    click_button 'Continue'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    if FeatureFlag.active?(:reference_selection)
      click_on 'Review your references'
    else
      click_on 'Manage your references'
    end
  end

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_content("#{@first_reference.referee_type.capitalize.dasherize} reference from #{@first_reference.name}")
    expect(page).to have_content("#{@second_reference.referee_type.capitalize.dasherize} reference from #{@second_reference.name}")
  end

  def when_i_view_courses
    click_link 'Back to application'

    click_link 'Choose your course'
  end

  def then_i_can_see_that_i_need_to_select_courses
    expect(page).to have_content 'You can apply for up to 3 courses'
  end

  def when_i_add_a_course
    given_courses_exist

    click_link t('continue')
    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Primary (2XT2)'
    click_button t('continue')

    expect(page).to have_content 'You’ve added Primary (2XT2) to your application'
    expect(page).to have_content 'You can choose 2 more courses'
  end

  def and_i_visit_the_course_choices_section
    click_link 'Choose your courses'
  end

  def then_i_see_the_course_choice_review_page
    expect(page).to have_current_path candidate_interface_course_choices_review_path
  end

  def when_i_add_another_course
    click_link 'Add another course'

    choose 'Yes, I know where I want to apply'
    click_button t('continue')

    select 'Gorse SCITT (1N1)'
    click_button t('continue')

    choose 'Drama (2397)'
    click_button t('continue')

    expect(page).to have_content 'You’ve added Drama (2397) to your application'
    expect(page).to have_content 'You can choose 1 more course'
  end

  def and_i_complete_the_section
    choose 'No, not at the moment'
    click_button t('continue')
    choose t('application_form.completed_radio')
    click_button t('continue')
  end

  def and_i_receive_references
    receive_references
    if FeatureFlag.active?(:reference_selection)
      select_references_and_complete_section
    end
  end

  def and_i_submit_my_application
    @new_application_form = candidate_submits_application
  end

  def then_my_application_is_awaiting_provider_decision
    application_choice = @new_application_form.application_choices.first
    expect(application_choice.status).to eq 'awaiting_provider_decision'
  end
end

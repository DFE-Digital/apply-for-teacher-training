require 'rails_helper'

RSpec.feature 'Manually carry over unsubmitted applications' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'Carry over application and remove all application choices when new cycle opens' do
    FeatureFlag.activate(:decoupled_references)

    given_i_am_signed_in_as_a_candidate
    and_i_am_in_the_2020_recruitment_cycle
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_start_now
    and_i_click_go_to_my_application_form

    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses

    and_i_select_a_course
    and_i_complete_the_section
    and_i_submit_my_application
    and_my_application_is_awaiting_provider_decision
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_am_in_the_2020_recruitment_cycle
    allow(RecruitmentCycle).to receive(:current_year).and_return(2020)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      submitted_at: nil,
      candidate: @candidate,
      with_gcses: true,
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
    allow(RecruitmentCycle).to receive(:current_year).and_return(2021)
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 10, 15, 12, 0, 0))
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
    expect(page).not_to have_link 'Continue your application'
    expect(page).to have_content 'Carry on with your application for courses starting in the 2021 to 2022 academic year.'
    expect(page).to have_content 'Your courses have been removed. You can add them again now.'
  end

  def when_i_click_on_start_now
    expect(page).to have_content 'Carry on with your application for courses starting in the 2021 to 2022 academic year.'
    expect(page).to have_content 'Your courses have been removed. You can add them again now.'
    click_button 'Apply again'
  end

  def and_i_click_go_to_my_application_form
    click_link 'Go to your application form'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    click_on 'Manage your references'
  end

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_content("#{@first_reference.referee_type.capitalize.dasherize} reference from #{@first_reference.name}")
    expect(page).to have_content("#{@second_reference.referee_type.capitalize.dasherize} reference from #{@second_reference.name}")
  end

  def when_i_view_courses
    click_link 'Back to application'
    click_link 'Course choice'
  end

  def then_i_can_see_that_i_need_to_select_courses
    expect(page).to have_content 'You can apply for up to 3 courses'
  end

  def and_i_select_a_course
    given_courses_exist

    click_link 'Continue'
    choose 'Yes, I know where I want to apply'
    click_button 'Continue'

    select 'Gorse SCITT (1N1)'
    click_button 'Continue'

    choose 'Primary (2XT2)'
    click_button 'Continue'

    expect(page).to have_content 'You’ve added Primary (2XT2) to your application'
    expect(page).to have_content 'You can choose 2 more courses'
  end

  def and_i_complete_the_section
    choose 'No, not at the moment'
    click_button 'Continue'
    check t('application_form.completed_checkbox')
    click_button 'Continue'
  end

  def and_i_submit_my_application
    @new_application_form = candidate_submits_application
  end

  def and_my_application_is_awaiting_provider_decision
    application_choice = @new_application_form.application_choices.first
    expect(application_choice.status).to eq 'awaiting_provider_decision'
  end
end

require 'rails_helper'

RSpec.feature 'Automatically carry over unsubmitted applications' do
  include CandidateHelper

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 1)) do
      example.run
    end
  end

  scenario 'Carry over application and remove all application choices' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application
    and_the_recruitment_cycle_ends
    and_the_unsubmitted_application_carry_over_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_can_see_the_referees_i_previously_added

    when_i_view_courses
    then_i_can_see_that_i_need_to_select_courses

    and_i_select_a_course
    and_i_complete_the_section
    and_i_submit_my_application
    and_my_application_is_awaiting_references
  end

  def given_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsubmitted_application
    @application_form = create(
      :completed_application_form,
      submitted_at: nil,
      candidate: @candidate,
      with_gces: true,
      safeguarding_issues_status: :no_safeguarding_issues_to_declare,
    )
    create(
      :application_choice,
      status: :unsubmitted,
      application_form: @application_form,
    )
    @unrequested_references = create_list(:reference, 2, feedback_status: :not_requested_yet, application_form: @application_form)
  end

  def and_the_recruitment_cycle_ends
    Timecop.safe_mode = false
    Timecop.travel(Time.zone.local(2020, 10, 15, 12, 0, 0))
  ensure
    Timecop.safe_mode = true
  end

  def and_the_unsubmitted_application_carry_over_worker_runs
    CarryOverUnsubmittedApplicationsWorker.new.perform
  end

  def when_i_sign_in_again
    logout
    login_as(@candidate)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
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

  def then_i_can_see_the_referees_i_previously_added
    expect(page).to have_content('First referee')
    expect(page).to have_content('Second referee')
    @unrequested_references.each do |reference|
      expect(page).to have_content(reference.name)
    end
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

  def and_my_application_is_awaiting_references
    application_choice = @new_application_form.application_choices.first
    expect(application_choice.status).to eq 'awaiting_references'
  end
end

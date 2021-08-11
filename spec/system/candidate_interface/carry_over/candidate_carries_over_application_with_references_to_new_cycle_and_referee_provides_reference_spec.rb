require 'rails_helper'

RSpec.feature 'Carry over' do
  include CandidateHelper
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(mid_cycle) do
      example.run
    end
  end

  scenario 'Candidate carries over application with reference to new cycle and referees provide references' do
    given_i_am_signed_in_as_a_candidate
    when_i_have_an_unsubmitted_application
    and_reference_is_sent_to_referee
    and_the_recruitment_cycle_ends
    and_the_cancel_unsubmitted_applications_worker_runs

    when_i_sign_in_again
    and_i_visit_the_application_dashboard
    then_i_am_redirected_to_the_carry_over_interstitial

    when_i_click_on_continue
    then_i_see_a_copy_of_my_application
    and_i_can_see_the_referee_i_previously_added

    when_i_sign_out_as_the_candidate
    and_i_sign_in_as_the_referee
    then_i_am_asked_to_provide_a_reference_for_the_candidate

    when_i_submit_the_outstanding_reference
    and_sign_back_in_as_the_candidate
    then_i_see_the_reference_completed
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
    @reference = create(
      :reference,
      feedback_status: :feedback_requested,
      application_form: @application_form,
    )
  end

  def and_reference_is_sent_to_referee
    RefereeMailer.reference_request_email(@reference).deliver_now
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

  def and_i_can_see_the_referee_i_previously_added
    expect(page).to have_content("#{@reference.name}: Awaiting response")
  end

  def when_i_sign_out_as_the_candidate
    logout
  end

  def and_i_sign_in_as_the_referee
    open_email(@reference.email_address)
    click_sign_in_link(current_email)
  end

  def then_i_am_asked_to_provide_a_reference_for_the_candidate
    expect(page).to have_content("Confirm how you know #{@application_form.full_name}")
  end

  def when_i_submit_the_outstanding_reference
    choose 'Yes'
    click_button t('continue')
    choose 'No'
    click_button t('continue')
    fill_in 'Your reference', with: 'This is a reference for the candidate.'
    click_button t('continue')
    click_button t('referee.review.submit')
  end

  def and_sign_back_in_as_the_candidate
    visit candidate_interface_application_complete_path
    login_as(@candidate)
  end

  def then_i_see_the_reference_completed
    expect(page).to have_content("#{@reference.name}: Reference received")
  end
end

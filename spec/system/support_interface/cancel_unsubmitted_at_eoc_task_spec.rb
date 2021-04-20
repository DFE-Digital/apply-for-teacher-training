require 'rails_helper'

RSpec.feature 'Cancel unsubmitted applications support task', sidekiq: true do
  include DfESignInHelpers
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(after_apply_2_deadline) { example.run }
  end

  scenario 'Support user performs the cancel unsubmitted applications at EoC task' do
    given_i_have_a_candidate_with_an_unsubmitted_application

    when_i_am_a_support_user
    and_i_visit_the_support_tasks_page
    and_i_click_on_cancel_unsubmitted_task
    and_i_click_the_i_am_sure_button
    then_i_see_that_the_job_has_been_scheduled

    when_i_lookup_the_candidates_application
    then_i_can_see_that_the_application_has_been_cancelled
  end

  def when_i_am_a_support_user
    sign_in_as_support_user
  end

  def given_i_have_a_candidate_with_an_unsubmitted_application
    @application_form = create :completed_application_form, submitted_at: nil
    create :application_choice, application_form: @application_form, status: :unsubmitted
  end

  def and_i_visit_the_support_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_cancel_unsubmitted_task
    click_link 'Cancel applications'
  end

  def and_i_click_the_i_am_sure_button
    click_button 'Yes, I’m sure – cancel all unsubmitted applications'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled job to cancel unsubmitted applications that reached end-of-cycle'
  end

  def when_i_lookup_the_candidates_application
    visit support_interface_candidate_path(@application_form.candidate_id)
  end

  def then_i_can_see_that_the_application_has_been_cancelled
    expect(page).to have_content('Ended without success')
  end
end

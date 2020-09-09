require 'rails_helper'

RSpec.feature 'Reject applications awaiting references suppor task', sidekiq: true do
  include DfESignInHelpers

  around do |example|
    Timecop.freeze(Date.new(2020, 8, 24)) { example.run }
  end

  scenario 'Support user performs the reject awaiting references at EoC task' do
    given_i_have_a_candidate_awaiting_references
    and_the_2020_recruitment_cycle_has_ended

    when_i_am_a_support_user
    and_i_visit_the_support_tasks_page
    and_i_click_on_reject_awaiting_references_task
    then_i_see_that_the_job_has_been_scheduled

    when_i_lookup_the_candidates_application
    then_i_can_see_that_the_application_has_been_rejected
  end

  def when_i_am_a_support_user
    sign_in_as_support_user
  end

  def given_i_have_a_candidate_awaiting_references
    @application_form = create :completed_application_form
    create :awaiting_references_application_choice, application_form: @application_form
  end

  def and_the_2020_recruitment_cycle_has_ended
    Timecop.travel(Time.zone.local(2020, 9, 19, 12, 0, 0))
  end

  def and_i_visit_the_support_tasks_page
    visit support_interface_tasks_path
  end

  def and_i_click_on_reject_awaiting_references_task
    click_button 'Reject applications awaiting references'
  end

  def then_i_see_that_the_job_has_been_scheduled
    expect(page).to have_content 'Scheduled job to reject applications awaiting references'
  end

  def when_i_lookup_the_candidates_application
    visit support_interface_candidate_path(@application_form.candidate_id)
  end

  def then_i_can_see_that_the_application_has_been_rejected
    expect(page).to have_content('Ended without success')
  end
end

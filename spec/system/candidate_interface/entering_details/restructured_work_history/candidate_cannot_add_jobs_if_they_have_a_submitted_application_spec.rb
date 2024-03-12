require 'rails_helper'

RSpec.feature 'Trying to enter work history' do
  include CandidateHelper

  scenario 'Candidate does not see Add job or Add another job buttons' do
    given_i_am_signed_in
    and_i_have_completed_work_history
    and_i_have_a_submitted_application
    when_i_view_work_history
    then_i_do_not_see_an_option_to_add_another_job
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_have_completed_work_history
    @application_form_can_complete_work_history = create(:completed_application_form,
                                                         full_work_history: true,
                                                         candidate: @current_candidate,
                                                         work_history_status: :can_complete)
  end

  def when_i_view_work_history
    visit candidate_interface_continuous_applications_details_path
    click_on 'Work history'
  end

  def and_i_have_a_submitted_application
    create(:application_choice, :awaiting_provider_decision, application_form: @application_form_can_complete_work_history)
  end

  def then_i_do_not_see_an_option_to_add_another_job
    expect(page).to have_content 'Work history'
    expect(page).to have_no_content 'Add another job'
    expect(page).to have_no_content 'Add job'
  end
end

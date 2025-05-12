require 'rails_helper'

RSpec.describe 'Trying to enter work history' do
  include CandidateHelper

  scenario 'Candidate does see Add job or Add another job buttons' do
    given_i_am_signed_in_with_one_login
    and_i_have_completed_work_history
    and_i_have_a_submitted_application
    when_i_view_work_history
    then_i_do_see_an_option_to_add_another_job
  end

  def and_i_have_completed_work_history
    @application_form_can_complete_work_history = create(:completed_application_form,
                                                         full_work_history: true,
                                                         candidate: @current_candidate,
                                                         work_history_status: :can_complete)
  end

  def when_i_view_work_history
    visit candidate_interface_details_path
    click_on 'Work history'
  end

  def and_i_have_a_submitted_application
    create(:application_choice, :awaiting_provider_decision, application_form: @application_form_can_complete_work_history)
  end

  def then_i_do_see_an_option_to_add_another_job
    expect(page).to have_content 'Check your work history'
    expect(page).to have_content 'Add another job'
  end
end

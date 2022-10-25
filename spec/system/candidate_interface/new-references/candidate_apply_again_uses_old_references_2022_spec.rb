require 'rails_helper'

RSpec.feature 'Candidates on 2022 which apply again before the apply 2 deadline' do
  include CandidateHelper
  include CycleTimetableHelper

  before do
    TestSuiteTimeMachine.travel_permanently_to(CycleTimetable.apply_1_deadline(2022))
  end

  scenario 'Candidate carries over their application to the new cycle' do
    given_the_new_reference_flow_feature_flag_is_on

    given_i_am_signed_in
    and_i_have_unsuccessful_application

    when_apply_1_deadline_has_passed
    when_i_visit_the_site
    and_i_carry_over_my_application
    then_i_should_see_the_old_references_section
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow)
  end

  def and_i_have_unsuccessful_application
    @application_form = create(:completed_application_form, submitted_at: 2.days.ago, candidate: @candidate)
    create_list(:application_choice, 2, status: :rejected, application_form: @application_form)

    @pending_reference = create(:reference, :feedback_requested, application_form: @application_form)
    @declined_reference = create(:reference, :feedback_refused, application_form: @application_form)
    @cancelled_reference = create(:reference, :cancelled, application_form: @application_form)
    @selected_reference = create(:selected_reference, application_form: @application_form)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_apply_1_deadline_has_passed
    TestSuiteTimeMachine.advance_time_to(after_apply_1_deadline(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR))
  end

  def and_i_carry_over_my_application
    click_on 'Apply again'
  end

  def then_i_should_see_the_old_references_section
    expect(page).to have_current_path candidate_interface_application_form_path, ignore_query: true
    expect(page).to have_content 'Select 2 references'
    expect(page).to have_content 'Select the 2 references you want to include in your application.'
  end

  def and_i_sign_in_again
    logout

    login_as(@candidate)
  end
end

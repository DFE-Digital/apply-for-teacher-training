require 'rails_helper'

RSpec.feature 'New references flow' do
  include CandidateHelper
  include CycleTimetableHelper

  around do |example|
    Timecop.freeze(CycleTimetable.apply_1_deadline(2022) - 1.day) do
      example.run
    end
  end

  scenario 'Candidate carries over their application to the new cycle' do
    given_the_new_reference_flow_feature_flag_is_off

    given_i_am_signed_in

    and_i_have_an_unsubmitted_application_with_references
    when_i_visit_the_site
    then_i_should_see_the_old_references_section

    given_the_new_reference_flow_feature_flag_is_on
    when_the_apply1_deadline_passes
    and_i_sign_in_again
    and_i_visit_the_application_dashboard
    and_i_have_to_carry_my_application_over
    then_i_see_the_new_references_section
    and_references_is_marked_as_incomplete

    when_i_click_on_the_new_references_section
    then_i_see_the_new_states_of_my_references
  end

  def given_the_new_reference_flow_feature_flag_is_off
    FeatureFlag.deactivate(:new_references_flow)
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow)
  end

  def and_i_have_an_unsubmitted_application_with_references
    @application_form = create(:completed_application_form, submitted_at: nil, candidate: @candidate)

    @pending_reference = create(:reference, :feedback_requested, application_form: @application_form)
    @declined_reference = create(:reference, :feedback_refused, application_form: @application_form)
    @cancelled_reference = create(:reference, :cancelled, application_form: @application_form)
    @selected_reference = create(:selected_reference, application_form: @application_form)
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_should_see_the_old_references_section
    expect(page).to have_content 'Select 2 references'
  end

  def when_the_apply1_deadline_passes
    Timecop.travel(CycleTimetable.apply_1_deadline(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR) + 1.day)
  end

  def and_i_sign_in_again
    logout

    login_as(@candidate)
  end

  def and_i_have_to_carry_my_application_over
    expect(page).to have_current_path candidate_interface_start_carry_over_path
    click_button 'Continue'
  end

  def then_i_see_the_new_references_section
    expect(links_under_safeguarding).to include('References to be requested if you accept an offer')
  end

  def links_under_safeguarding
    safeguarding_section.all('a').map(&:text)
  end

  def when_i_click_on_the_new_references_section
    click_link 'References to be requested if you accept an offer'
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_references_is_marked_as_incomplete
    expect(safeguarding_section.text.downcase).to include('references to be requested if you accept an offer incomplete')
  end

  def new_application_form
    ApplicationForm.find_by(previous_application_form_id: @application_form.id)
  end

  def then_i_see_the_new_states_of_my_references
    expect(new_application_form.application_references.map(&:feedback_status)).to eq(
      %w[feedback_provided feedback_provided not_requested_yet feedback_provided],
    )
  end

  def safeguarding_section
    find(:xpath, "//h2[contains(text(),'Safeguarding')]/..")
  end
end

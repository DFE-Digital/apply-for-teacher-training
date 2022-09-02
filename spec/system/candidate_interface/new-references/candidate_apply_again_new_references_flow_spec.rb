require 'rails_helper'

RSpec.feature 'Candidates in the 2023 cycle, applying again with the new references flow' do
  include CandidateHelper
  include CycleTimetableHelper

  around do |example|
    Timecop.travel(CycleTimetable.apply_1_deadline(2023)) do
      example.run
    end
  end

  scenario 'Candidate applies again' do
    given_the_new_reference_flow_feature_flag_is_on

    given_i_am_signed_in
    and_i_have_unsuccessful_application

    when_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_am_redirected_to_the_new_application_form
    and_i_am_told_my_new_application_is_ready_to_review
    then_i_should_see_the_new_references_section

    when_i_click_on_the_references_section
    then_i_see_the_new_states_of_my_references
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def given_the_new_reference_flow_feature_flag_is_on
    FeatureFlag.activate(:new_references_flow)
  end

  def and_i_have_unsuccessful_application
    @application_form = create(:application_form, submitted_at: 2.days.ago, candidate: @candidate, application_references: [])
    create(:application_choice, status: :rejected, application_form: @application_form)

    @pending_reference = create(:reference, :feedback_requested, application_form: @application_form)
    @declined_reference = create(:reference, :feedback_refused, name: 'Mr declined', application_form: @application_form)
    @cancelled_reference = create(:reference, :cancelled, name: 'Mr cancelled', application_form: @application_form)
    @not_sent_reference = create(:reference, :not_requested_yet, application_form: @application_form)
    @selected_reference = create(:selected_reference, application_form: @application_form)
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def and_i_am_redirected_to_the_new_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end

  def and_i_am_told_my_new_application_is_ready_to_review
    expect(page).to have_content('We’ve copied your application. Please review all sections.')
  end

  def then_i_should_see_the_new_references_section
    expect(page).to have_content 'References to be requested if you accept an offer Incomplete'
  end

  def when_i_click_on_the_references_section
    click_on 'References to be requested if you accept an offer'
  end

  def new_application_form
    ApplicationForm.find_by(previous_application_form_id: @application_form.id)
  end

  def then_i_see_the_new_states_of_my_references
    expect(new_application_form.application_references.map(&:name)).not_to include(%w[Mr cancelled Mr declined])
    expect(new_application_form.application_references.count).to eq 3
    expect(new_application_form.application_references.first.feedback_status).to eq 'not_requested_yet'
    expect(new_application_form.application_references.second.feedback_status).to eq 'not_requested_yet'
    expect(new_application_form.application_references.third.feedback_status).to eq 'feedback_provided'
    expect(page).to have_current_path(candidate_interface_new_references_review_path)
    expect(page.text).to include @pending_reference.name
    expect(page.text).to include @not_sent_reference.name
    expect(page.text).to include "#{@selected_reference.name} will not be asked to give you another reference"
  end

  def and_i_sign_in_again
    logout

    login_as(@candidate)
  end
end

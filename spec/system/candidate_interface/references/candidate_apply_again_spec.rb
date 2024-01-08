require 'rails_helper'

RSpec.feature 'Candidates in the 2023 cycle, applying again' do
  include CandidateHelper

  scenario 'Candidate applies again', time: after_apply_1_deadline(2023) do
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

  def and_i_have_unsuccessful_application
    travel_temporarily_to(before_apply_1_deadline(2023)) do
      @application_form = create(:application_form, submitted_at: Time.zone.now, candidate: @candidate, application_references: [])
      create(:application_choice, status: :rejected, application_form: @application_form)

      @pending_reference = create(:reference, :feedback_requested, application_form: @application_form)
      @declined_reference = create(:reference, :feedback_refused, name: 'Mr declined', application_form: @application_form)
      @cancelled_reference = create(:reference, :cancelled, name: 'Mr cancelled', application_form: @application_form)
      @not_sent_reference = create(:reference, :not_requested_yet, application_form: @application_form)
      @selected_reference = create(:selected_reference, application_form: @application_form)
    end
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_link_or_button 'Apply again'
  end

  def and_i_am_redirected_to_the_new_application_form
    expect(page).to have_current_path candidate_interface_application_form_path
  end

  def and_i_am_told_my_new_application_is_ready_to_review
    expect(page).to have_content('We’ve copied your application. Please review all sections.')
  end

  def then_i_should_see_the_new_references_section
    expect(page).to have_content 'References to be requested if you accept an offer Complete'
  end

  def when_i_click_on_the_references_section
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def new_application_form
    ApplicationForm.find_by(previous_application_form_id: @application_form.id)
  end

  def then_i_see_the_new_states_of_my_references
    references = new_application_form.application_references.creation_order

    expect(references.map(&:name).intersect?(['Mr cancelled', 'Mr declined'])).not_to be(true)
    expect(references.count).to eq(3)
    expect(references.first.feedback_status).to eq('not_requested_yet')
    expect(references.second.feedback_status).to eq('not_requested_yet')
    expect(references.third.feedback_status).to eq('feedback_provided')

    expect(page).to have_current_path(candidate_interface_references_review_path)
    expect(page.text).to include(@pending_reference.name)
    expect(page.text).to include(@not_sent_reference.name)
    expect(page.text).to include("#{@selected_reference.name} has already given a reference.")
    expect(page.text).to include('If you accept an offer, the training provider will see the reference.')
  end

  def and_i_sign_in_again
    logout

    login_as(@candidate)
  end
end

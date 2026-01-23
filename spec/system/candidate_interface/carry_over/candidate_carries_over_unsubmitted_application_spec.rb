require 'rails_helper'

RSpec.describe 'Carry over unsubmitted application' do
  include CandidateHelper

  scenario 'Candidate carries over their application to the new cycle' do
    given_i_am_signed_in_with_one_login
    and_i_have_an_unsubmitted_application_with_references

    when_the_apply_deadline_passes
    and_i_sign_in_again # Carry over occurs
    then_i_see_the_references_section
    and_references_is_marked_as_incomplete

    when_i_click_on_the_references_section
    then_i_see_the_new_states_of_my_references

    when_i_visit_the_application_dashboard
    then_i_am_on_your_details_page
  end

  def and_i_have_an_unsubmitted_application_with_references
    @application_form = create(:completed_application_form, recruitment_cycle_year: 2024, submitted_at: nil, candidate: @current_candidate)

    @pending_reference = create(:reference, :feedback_requested, application_form: @application_form)
    @declined_reference = create(:reference, :feedback_refused, application_form: @application_form)
    @cancelled_reference = create(:reference, :cancelled, application_form: @application_form)
    @selected_reference = create(:selected_reference, application_form: @application_form)
  end

  def when_the_apply_deadline_passes
    advance_time_to(after_apply_deadline)
  end

  def and_i_sign_in_again
    click_link_or_button 'Sign out'

    given_i_am_signed_in_with_one_login
  end

  def and_i_carry_over_my_application
    expect(page).to have_current_path candidate_interface_application_choices_path

    within 'form.button_to[action="/candidate/application/carry-over"]' do
      click_link_or_button 'Update your details'
    end
  end

  def then_i_see_the_references_section
    expect(links_under_safeguarding).to include('References to be requested if you accept an offer')
  end

  def links_under_safeguarding
    safeguarding_section.all('a').map(&:text)
  end

  def when_i_click_on_the_references_section
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def when_i_visit_the_application_dashboard
    visit candidate_interface_interstitial_path
  end

  def and_references_is_marked_as_incomplete
    expect(safeguarding_section.text.downcase).to include('references to be requested if you accept an offer incomplete')
  end

  def new_application_form
    ApplicationForm.find_by(previous_application_form_id: @application_form.id)
  end

  def then_i_see_the_new_states_of_my_references
    expect(new_application_form.application_references.creation_order.map(&:feedback_status)).to eq(
      %w[feedback_provided feedback_provided not_requested_yet feedback_provided],
    )
  end

  def safeguarding_section
    find(:xpath, "//h2[contains(text(),'Safeguarding')]/..")
  end
end

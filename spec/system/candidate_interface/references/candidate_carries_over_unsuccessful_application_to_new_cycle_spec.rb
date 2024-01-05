require 'rails_helper'

RSpec.describe 'Candidate can carry over unsuccessful application to a new recruitment cycle after the apply 2 deadline and move the references' do
  before do
    TestSuiteTimeMachine.travel_permanently_to(mid_cycle(2022))
  end

  scenario 'when an unsuccessful candidate returns in the next recruitment cycle they can re-apply by carrying over their original application' do
    given_i_am_signed_in

    and_i_have_an_application_with_a_rejection_and_references

    when_the_apply2_deadline_passes
    and_i_visit_my_application_complete_page
    then_i_see_the_carry_over_inset_text

    when_i_click_apply_again
    then_i_can_see_application_details
    then_i_see_the_new_references_section

    when_i_click_on_the_new_references_section
    then_i_see_the_new_states_of_my_references
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_application_with_a_rejection_and_references
    @application_form = create(:application_form, :with_completed_references, candidate: @candidate)
    create(:application_choice, :rejected, application_form: @application_form)

    create(
      :reference,
      feedback_status: :not_requested_yet,
      application_form: @application_form,
    )
  end

  def when_the_apply2_deadline_passes
    advance_time_to(after_apply_2_deadline(2022))
  end

  def and_i_visit_my_application_complete_page
    logout
    login_as(@candidate)
    visit candidate_interface_application_complete_path
  end

  def then_i_see_the_carry_over_inset_text
    expect(page).to have_content 'You can apply for courses starting in the 2023 to 2024 academic year instead.'
  end

  def when_i_click_apply_again
    click_link_or_button 'Apply again'
  end

  def then_i_can_see_application_details
    expect(page).to have_content('Personal information Completed')
    click_link_or_button 'Personal information'
    expect(page).to have_content(@application_form.full_name)
    click_link_or_button t('continue')
  end

  def when_i_click_on_the_new_references_section
    click_link_or_button 'References to be requested if you accept an offer'
  end

  def then_i_see_the_new_references_section
    expect(links_under_safeguarding).to include('References to be requested if you accept an offer')
  end

  def then_i_see_the_new_states_of_my_references
    expect(new_application_form.application_references.creation_order.map(&:feedback_status)).to eq(
      %w[feedback_provided feedback_provided not_requested_yet],
    )
  end

  def new_application_form
    ApplicationForm.find_by(previous_application_form_id: @application_form.id)
  end

  def links_under_safeguarding
    find(:xpath, "//h2[contains(text(),'Safeguarding')]/..").all('a').map(&:text)
  end
end

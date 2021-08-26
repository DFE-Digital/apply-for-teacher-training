require 'rails_helper'

RSpec.feature 'Candidate applying again' do
  include CandidateHelper

  scenario 'Can replace a completed reference' do
    given_the_pilot_is_open
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application_with_references
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_am_told_my_new_application_is_ready_to_edit
    and_i_see_a_copy_of_my_application

    when_i_view_referees
    then_i_cannot_change_referee_details

    when_i_delete_a_referee
    then_i_can_see_i_only_have_one_referee

    when_i_add_a_new_referee
    then_i_can_see_i_have_two_referees
    and_references_for_original_application_are_not_affected

    when_my_referee_refuses_to_provide_a_reference
    and_i_try_to_manually_destroy_the_reference
    then_i_see_the_review_page
    and_my_reference_has_not_been_destroyed
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application_with_references
    @application_form = create(:completed_application_form, :with_gcses, candidate: @candidate, safeguarding_issues_status: :no_safeguarding_issues_to_declare)
    create(:application_choice, status: :rejected, application_form: @application_form)
    @completed_references = create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @application_form)
    @refused_reference = create(:reference, feedback_status: :feedback_refused, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Apply again'
  end

  def and_i_am_told_my_new_application_is_ready_to_edit
    expect(page).to have_content('We’ve copied your application. Please review all sections.')
  end

  def and_i_see_a_copy_of_my_application
    expect(page).to have_title('Your application')
  end

  def when_i_view_referees
    click_on 'Review your references'
  end

  def then_i_cannot_change_referee_details
    expect(page).not_to have_link('Change')
  end

  def when_i_delete_a_referee
    click_on "Delete reference #{@completed_references[0].name}"
    click_on I18n.t('application_form.references.delete_reference.confirm')
  end

  def then_i_can_see_i_only_have_one_referee
    expect(page).not_to have_content @completed_references[0].name
    expect(page).to have_content @completed_references[1].name
  end

  def when_i_add_a_new_referee
    click_link 'Request a second reference'
    click_link t('continue')
    choose 'Academic'
    click_button t('continue')

    candidate_fills_in_referee(
      name: 'Bob Lawblob',
      email_address: 'bob@lawblob.com',
      relationship: 'I wrote content for him on boblawblobslawblog.com',
    )

    choose 'Yes, send a reference request now'
    click_button t('save_and_continue')

    @new_reference = ApplicationReference.find_by!(email_address: 'bob@lawblob.com')
  end

  def then_i_can_see_i_have_two_referees
    expect(page).to have_content @completed_references[1].name
    expect(page).to have_content @new_reference.name
  end

  def and_references_for_original_application_are_not_affected
    original_referees = @application_form.reload.application_references
    expect(original_referees.map(&:name)).to match_array([
      @completed_references[0].name,
      @completed_references[1].name,
      @refused_reference.name,
    ])
  end

  def when_my_referee_refuses_to_provide_a_reference
    @new_reference.feedback_refused!
  end

  def and_i_try_to_manually_destroy_the_reference
    visit candidate_interface_destroy_reference_path(@new_reference.id)
  end

  def then_i_see_the_review_page
    visit candidate_interface_references_review_path
  end

  def and_my_reference_has_not_been_destroyed
    expect(@new_reference.reload.feedback_status).to eq 'feedback_refused'
  end
end

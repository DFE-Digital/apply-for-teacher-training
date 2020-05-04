require 'rails_helper'

RSpec.feature 'Candidate applying again' do
  include CandidateHelper

  scenario 'Can replace a completed reference' do
    given_the_pilot_is_open
    and_apply_again_feature_flag_is_active
    and_i_am_signed_in_as_a_candidate

    when_i_have_an_unsuccessful_application_with_references
    and_i_visit_the_application_dashboard
    and_i_click_on_apply_again
    and_i_click_on_start_now

    then_i_see_a_copy_of_my_application

    when_i_delete_a_referee
    then_i_can_see_i_only_have_one_referee

    when_i_add_a_new_referee
    then_i_can_see_i_have_two_referees
    and_references_for_original_application_are_not_affected
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def and_apply_again_feature_flag_is_active
    FeatureFlag.activate('apply_again')
  end

  def and_i_am_signed_in_as_a_candidate
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def when_i_have_an_unsuccessful_application_with_references
    @application_form = create(:completed_application_form, candidate: @candidate)
    create(:application_choice, status: :rejected, application_form: @application_form)
    @completed_references = create_list(:reference, 2, feedback_status: :feedback_provided, application_form: @application_form)
    @refused_reference = create(:reference, feedback_status: :feedback_refused, application_form: @application_form)
  end

  def and_i_visit_the_application_dashboard
    visit candidate_interface_application_complete_path
  end

  def and_i_click_on_apply_again
    click_on 'Do you want to apply again?'
  end

  def and_i_click_on_start_now
    click_on 'Start now'
  end

  def then_i_see_a_copy_of_my_application
    expect(page).to have_content('Your new application is ready for editing')
  end

  def when_i_delete_a_referee
    click_on 'Referees'
    click_on "Delete referee #{@completed_references[0].name}"
    click_on I18n.t('application_form.referees.sure_delete_entry')
  end

  def then_i_can_see_i_only_have_one_referee
    expect(page).not_to have_content @completed_references[0].name
    expect(page).to have_content @completed_references[1].name
  end

  def when_i_add_a_new_referee
    click_on 'Add a second referee'
    choose 'Academic'
    click_button 'Continue'

    candidate_fills_in_referee(
      name: 'Bob Example',
      email: 'bob@example.com',
    )
    click_button 'Save and continue'
  end

  def then_i_can_see_i_have_two_referees
    expect(page).to have_content @completed_references[1].name
    expect(page).to have_content 'Bob Example'
  end

  def and_references_for_original_application_are_not_affected
    original_referees = @application_form.reload.application_references
    expect(original_referees.map(&:name)).to match_array([
      @completed_references[0].name,
      @completed_references[1].name,
      @refused_reference.name,
    ])
  end
end

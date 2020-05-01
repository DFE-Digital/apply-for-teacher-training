require 'rails_helper'

RSpec.describe 'Candidate can see their rejection reasons on apply again' do
  scenario 'when a candidate visits their apply again application form they can see apply1 rejection reasons' do
    given_apply_again_rejection_reasons_is_active
    and_i_am_signed_in
    and_i_have_an_apply1_application_with_3_rejections
    and_i_have_started_my_apply_again_application_form

    when_i_visit_my_apply_again_application_form
    then_i_can_see_my_previous_rejection_reasons
  end

  def given_apply_again_rejection_reasons_is_active
    FeatureFlag.activate('apply_again_rejection_reasons')
  end

  def and_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_i_have_an_apply1_application_with_3_rejections
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create_list(:application_choice, 3, :with_rejection, application_form: @application_form)
  end

  def and_i_have_started_my_apply_again_application_form
    create(:application_form, candidate: @candidate, phase: :apply_2)
  end

  def when_i_visit_my_apply_again_application_form
    visit candidate_interface_application_form_path
  end

  def then_i_can_see_my_previous_rejection_reasons
    expect(page).to have_content(@application_form.application_choices.first.rejection_reason)
    expect(page).to have_content(@application_form.application_choices.second.rejection_reason)
    expect(page).to have_content(@application_form.application_choices.third.rejection_reason)
  end
end

require 'rails_helper'

RSpec.describe 'Candidate can see their structured reasons for rejection when reviewing their application' do
  scenario 'when a candidate visits their apply again application form they can see apply1 rejection reasons' do
    given_i_am_signed_in
    and_structured_rejection_reasons_feature_is_active
    and_i_have_an_apply1_application_with_3_rejections

    when_i_visit_my_application_complete_page

    then_i_can_see_my_rejection_reasons
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_structured_rejection_reasons_feature_is_active
    FeatureFlag.activate(:structured_reasons_for_rejection)
  end

  def and_i_have_an_apply1_application_with_3_rejections
    @application_form = create(:completed_application_form, :with_completed_references, candidate: @candidate)
    create_list(:application_choice, 3, :with_structured_rejection_reasons, application_form: @application_form)
  end

  def when_i_visit_my_application_complete_page
    visit candidate_interface_application_complete_path
  end

  def then_i_can_see_my_rejection_reasons
    expect(page).to have_content('Quality of application')
    expect(page).to have_content('Use a spellchecker.')
  end
end

require 'rails_helper'

RSpec.feature 'Candidate becomes eligible for an adviser' do
  include CandidateHelper

  it 'displays the adviser sign up CTA when eligible' do
    given_i_am_signed_in
    and_the_adviser_sign_up_feature_flag_is_disabled

    when_i_have_an_eligible_application
    and_i_visit_the_application_form_page
    then_i_should_not_see_the_adviser_cta

    when_the_adviser_sign_up_feature_flag_is_enabled
    and_i_visit_the_application_form_page
    then_i_should_see_the_adviser_cta

    when_i_remove_my_degrees
    and_i_visit_the_application_form_page
    then_i_should_not_see_the_adviser_cta
  end

  def given_i_am_signed_in
    @candidate = create(:candidate)
    login_as(@candidate)
  end

  def and_the_adviser_sign_up_feature_flag_is_disabled
    FeatureFlag.deactivate(:adviser_sign_up)
  end

  def and_i_visit_the_application_form_page
    visit candidate_interface_application_form_path
  end

  def when_the_adviser_sign_up_feature_flag_is_enabled
    FeatureFlag.activate(:adviser_sign_up)
  end

  def when_i_have_completed_my_application
    candidate_completes_application_form
  end

  def when_i_have_an_eligible_application
    create(:application_form_eligible_for_adviser, candidate: @candidate)
  end

  def then_i_should_see_the_adviser_cta
    expect(page).to have_link(t('application_form.adviser_sign_up.call_to_action'))
  end

  def when_i_remove_my_degrees
    @candidate.current_application.application_qualifications.degrees.destroy_all
  end

  def then_i_should_not_see_the_adviser_cta
    expect(page).not_to have_link(t('application_form.adviser_sign_up.call_to_action'))
  end
end

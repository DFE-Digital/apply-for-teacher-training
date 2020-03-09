require 'rails_helper'

RSpec.feature 'Entering their suitability to work with children' do
  include CandidateHelper

  scenario 'Candidate declares any safeguarding issues' do
    given_i_am_signed_in
    and_the_suitability_to_work_with_children_feature_flag_is_off
    when_i_visit_the_site
    then_i_dont_see_declaring_any_safeguarding_issues

    given_the_suitability_to_work_with_children_feature_flag_is_on
    when_i_visit_the_site
    then_i_see_declaring_any_safeguarding_issues
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def and_the_suitability_to_work_with_children_feature_flag_is_off
    FeatureFlag.deactivate('suitability_to_work_with_children')
  end

  def then_i_dont_see_declaring_any_safeguarding_issues
    expect(page).not_to have_content('Declaring any safeguarding issues')
  end

  def given_the_suitability_to_work_with_children_feature_flag_is_on
    FeatureFlag.activate('suitability_to_work_with_children')
  end

  def then_i_see_declaring_any_safeguarding_issues
    expect(page).to have_content(t('page_titles.suitability_to_work_with_children'))
  end
end

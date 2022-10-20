require 'rails_helper'

RSpec.feature 'Candidate attempts to submit their application with a removed site' do
  include CandidateHelper

  around do |example|
    old_references = CycleTimetable.apply_opens(ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR)
    Timecop.freeze(old_references) { example.run }
  end

  it 'The location that the candidate picked has been removed by the provider' do
    given_the_new_reference_flow_feature_flag_is_off

    given_i_complete_my_application
    and_the_selected_courses_site_has_been_removed_by_the_provider
    when_i_submit_my_application
    then_i_cannot_proceed
  end

  def given_the_new_reference_flow_feature_flag_is_off
    FeatureFlag.deactivate(:new_references_flow)
  end

  def given_i_complete_my_application
    candidate_completes_application_form
  end

  def and_the_selected_courses_site_has_been_removed_by_the_provider
    current_candidate.current_application.application_choices.first.course_option.update!(site_still_valid: false)
  end

  def when_i_submit_my_application
    click_link 'Check and submit your application'
    click_link t('continue')
  end

  def then_i_cannot_proceed
    expect(page).to have_content('There is a problem')
    expect(page).to have_content("The location you’ve chosen for ‘#{current_candidate.current_application.application_choices.first.course.provider_and_name_code}’ has been removed by the provider. Choose a different location.")
  end
end

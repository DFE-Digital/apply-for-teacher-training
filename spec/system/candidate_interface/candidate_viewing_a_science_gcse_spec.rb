require 'rails_helper'

RSpec.feature 'Candidate viewing Science GCSE' do
  include CandidateHelper

  scenario 'Candidate views a Science GCSE only when a primary course is chosen' do
    given_i_am_signed_in
    when_i_visit_the_site
    then_i_see_science_gcse

    given_conditional_science_gcse_feature_flag_is_on
    when_i_visit_the_site
    then_i_dont_see_science_gcse

    given_courses_exist
    when_i_add_a_primary_course
    then_i_see_science_gcse
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def when_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def then_i_see_science_gcse
    expect(page).to have_content('Science GCSE or equivalent')
  end

  def given_conditional_science_gcse_feature_flag_is_on
    FeatureFlag.activate('conditional_science_gcse')
  end

  def then_i_dont_see_science_gcse
    expect(page).not_to have_content('Science GCSE or equivalent')
  end

  def when_i_add_a_primary_course
    click_link 'Course choices'
    candidate_fills_in_course_choices
  end
end

require 'rails_helper'

RSpec.feature 'Entering their degrees' do
  include CandidateHelper

  scenario 'Candidate submits their international degree' do
    given_the_international_degrees_feature_flag_is_active
    given_i_am_signed_in
    and_i_visit_the_site
    when_i_click_on_degree
    then_i_see_the_undergraduate_degree_form

    # Add degree type after specifying Non-UK degree
    when_i_click_on_save_and_continue
    then_i_see_validation_errors_for_uk_degree
    when_i_check_non_uk_degree
    and_i_click_on_save_and_continue
    then_i_see_validation_errors_for_qualification_type
    and_i_fill_in_the_qualification_type
    and_i_click_on_save_and_continue
  end

  def given_the_international_degrees_feature_flag_is_active
    FeatureFlag.activate :international_degrees
  end

  def given_i_am_signed_in
    create_and_sign_in_candidate
  end

  def and_i_visit_the_site
    visit candidate_interface_application_form_path
  end

  def when_i_click_on_degree
    click_link 'Degree'
  end

  def then_i_see_the_undergraduate_degree_form
    expect(page).to have_content 'Add undergraduate degree'
  end

  def when_i_click_on_save_and_continue
    click_button t('application_form.degree.base.button')
  end

  def and_i_click_on_save_and_continue
    when_i_click_on_save_and_continue
  end

  def when_i_check_non_uk_degree
    choose 'Non-UK degree'
  end

  def then_i_see_validation_errors_for_uk_degree
    expect(page).to have_content 'Select if this is a UK degree or not'
  end

  def then_i_see_validation_errors_for_qualification_type
    expect(page).to have_content 'Enter your qualification type'
  end

  def and_i_fill_in_the_qualification_type
    fill_in 'Type of qualification', with: 'Bachelors degree'
  end
end

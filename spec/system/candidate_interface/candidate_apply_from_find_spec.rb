require 'rails_helper'

RSpec.describe 'A candidate arriving from Find with a course and provider code' do
  include FindAPIHelper

  scenario 'seeing their course information on the landing page' do
    given_i_have_arrived_from_find_with_valid_course_parameters
    then_i_should_see_the_landing_page
    and_i_should_see_the_provider_and_course_codes
    and_i_should_see_the_course_name_fetched_from_find
    and_i_should_be_able_to_apply_through_ucas
  end

  def given_i_have_arrived_from_find_with_valid_course_parameters
    stub_find_api_course_200('ABC', 'XYZ1', 'Biology')
    visit candidate_interface_apply_from_find_path providerCode: 'ABC', courseCode: 'XYZ1'
  end

  def then_i_should_see_the_landing_page
    expect(page).to have_content t('apply_from_find.heading')
  end

  def and_i_should_see_the_provider_and_course_codes
    expect(page).to have_content 'ABC'
    expect(page).to have_content 'XYZ1'
  end

  def and_i_should_see_the_course_name_fetched_from_find
    expect(page).to have_content 'Biology (XYZ1)'
  end

  def and_i_should_be_able_to_apply_through_ucas
    expect(page).to have_content t('apply_from_find.apply_button')
  end
end

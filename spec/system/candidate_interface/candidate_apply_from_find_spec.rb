require 'rails_helper'

RSpec.describe 'A candidate arriving from Find with a course and provider code' do
  scenario 'seeing their course information on the landing page' do
    when_i_have_arrive_from_find_with_invalid_course_parameters
    then_i_should_see_an_error_page

    when_i_have_arrived_from_find_with_valid_course_parameters
    then_i_should_see_the_landing_page
    and_i_should_see_the_provider_and_course_codes
    and_i_should_see_the_course_name_fetched_from_find
    and_i_should_be_able_to_apply_through_ucas

    when_i_visit_the_available_courses_page
    i_should_see_the_available_providers_and_courses
  end

  def when_i_have_arrive_from_find_with_invalid_course_parameters
    visit candidate_interface_apply_from_find_path providerCode: 'NOT', courseCode: 'REAL'
  end

  def then_i_should_see_an_error_page
    expect(page).to have_content 'We couldn’t find the course you’re looking for'
  end

  def when_i_have_arrived_from_find_with_valid_course_parameters
    create(:course, exposed_in_find: true, open_on_apply: true, code: 'XYZ1', name: 'Biology', provider: create(:provider, code: 'ABC'))
    visit candidate_interface_apply_from_find_path providerCode: 'ABC', courseCode: 'XYZ1'
  end

  def then_i_should_see_the_landing_page
    expect(page).to have_content t('apply_from_find.heading')
    expect(page).to have_link href: candidate_interface_apply_from_find_path(providerCode: 'ABC', courseCode: 'XYZ1')
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

  def when_i_visit_the_available_courses_page
    visit candidate_interface_providers_path
  end

  def i_should_see_the_available_providers_and_courses
    expect(page).to have_content 'Biology'
  end
end

require 'rails_helper'

RSpec.describe 'A candidate arriving from Find with a course and provider code' do
  scenario 'seeing their course information on the landing page' do
    given_the_pilot_is_open

    when_i_have_arrive_from_find_with_invalid_course_parameters
    then_i_should_see_an_error_page

    when_i_arrive_from_find_to_a_course_that_is_ucas_only
    then_i_should_see_the_landing_page
    and_i_should_see_the_provider_and_course_codes
    and_i_should_see_the_course_name
    and_i_should_be_able_to_apply_through_ucas_only

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_should_be_able_to_apply_through_apply

    when_i_visit_the_available_courses_page
    i_should_see_the_available_providers_and_courses

    given_the_pilot_is_not_open
    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_should_be_able_to_apply_through_ucas_only
  end

  def given_the_pilot_is_not_open
    FeatureFlag.deactivate('pilot_open')
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_have_arrive_from_find_with_invalid_course_parameters
    visit candidate_interface_apply_from_find_path providerCode: 'NOT', courseCode: 'REAL'
  end

  def then_i_should_see_an_error_page
    expect(page).to have_content 'We couldn’t find the course you’re looking for'
  end

  def when_i_arrive_from_find_to_a_course_that_is_ucas_only
    create(:course, exposed_in_find: true, open_on_apply: false, code: 'XYZ1', name: 'Biology', provider: create(:provider, code: 'ABC'))
    visit candidate_interface_apply_from_find_path providerCode: 'ABC', courseCode: 'XYZ1'
  end

  def when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    course = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    visit candidate_interface_apply_from_find_path providerCode: course.provider.code, courseCode: course.code
  end

  def then_i_should_see_the_landing_page
    expect(page).to have_content t('apply_from_find.heading')
    expect(page).to have_link href: candidate_interface_apply_from_find_path(providerCode: 'ABC', courseCode: 'XYZ1')
  end

  def and_i_should_see_the_provider_and_course_codes
    expect(page).to have_content 'ABC'
    expect(page).to have_content 'XYZ1'
  end

  def and_i_should_see_the_course_name
    expect(page).to have_content 'Biology (XYZ1)'
  end

  def and_i_should_be_able_to_apply_through_ucas_only
    expect(page).to have_content 'You must apply for this course on UCAS'
  end

  def and_i_should_be_able_to_apply_through_apply
    expect(page).to have_content 'You can apply for this course using a new GOV.UK service'
  end

  def when_i_visit_the_available_courses_page
    visit candidate_interface_providers_path
  end

  def i_should_see_the_available_providers_and_courses
    expect(page).to have_content 'Biology'
    expect(page).to have_content 'Potions'
  end
end

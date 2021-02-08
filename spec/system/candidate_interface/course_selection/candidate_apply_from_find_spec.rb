require 'rails_helper'

RSpec.describe 'A candidate arriving from Find with a course and provider code' do
  include FindAPIHelper

  scenario 'seeing their course information on the landing page' do
    given_the_pilot_is_open

    when_i_arrive_from_find_with_invalid_course_parameters
    then_i_should_see_an_error_page

    when_i_arrive_from_find_to_a_course_that_is_ucas_only
    then_i_should_see_the_landing_page
    and_i_should_see_the_provider_and_course_codes
    and_i_should_see_the_course_name
    then_i_should_be_able_to_apply_through_ucas_only
    and_i_should_see_locations_info_for_a_synced_course

    when_i_arrive_from_find_to_a_course_that_is_not_synced_in_apply
    then_i_should_be_able_to_apply_through_ucas_only
    and_i_should_see_locations_info_for_an_unsynced_course

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    then_i_should_be_able_to_apply_through_apply

    when_i_visit_the_available_courses_page
    then_i_should_see_the_available_providers_and_courses

    given_i_am_on_the_apply_through_apply_page
    when_i_do_not_make_a_choice_between_ucas_and_apply
    then_i_see_an_error

    when_i_choose_to_apply_through_apply
    and_i_confirm_i_am_not_already_signed_up
    then_i_see_the_sign_up_page

    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    and_i_choose_to_apply_through_ucas
    then_i_should_see_an_interstitial_page
    and_i_should_see_the_provider_and_course_codes
    and_i_should_see_location_details
    and_i_should_see_a_link_to_ucas

    given_the_pilot_is_not_open
    when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    then_i_should_be_able_to_apply_through_ucas_only
  end

  def given_the_pilot_is_not_open
    FeatureFlag.deactivate('pilot_open')
  end

  def given_the_pilot_is_open
    FeatureFlag.activate('pilot_open')
  end

  def when_i_arrive_from_find_with_invalid_course_parameters
    stub_find_api_course_404('NOT', 'REAL')
    visit candidate_interface_apply_from_find_path providerCode: 'NOT', courseCode: 'REAL'
  end

  def when_i_arrive_from_find_to_a_course_that_is_not_synced_in_apply
    stub_find_api_course_200('FINDABLE', 'COURSE', 'Biology')
    visit candidate_interface_apply_from_find_path providerCode: 'FINDABLE', courseCode: 'COURSE'
  end

  def then_i_should_see_an_error_page
    expect(page).to have_content 'We could not find the course you’re looking for'
  end

  def when_i_arrive_from_find_to_a_course_that_is_ucas_only
    course = create(:course, exposed_in_find: true, open_on_apply: false, code: 'XYZ1', name: 'Biology', provider: create(:provider, code: 'ABC'))
    site = create(:site, name: 'Site for a UCAS-only course', code: 'OOO', provider: course.provider)
    create(:course_option, course: course, site: site)

    visit candidate_interface_apply_from_find_path providerCode: 'ABC', courseCode: 'XYZ1'
  end

  def when_i_arrive_from_find_to_a_course_that_is_open_on_apply
    @course_on_apply = create(:course, exposed_in_find: true, open_on_apply: true, name: 'Potions')
    visit candidate_interface_apply_from_find_path providerCode: @course_on_apply.provider.code, courseCode: @course_on_apply.code
  end

  def then_i_should_see_the_landing_page
    expect(page).to have_content t('page_titles.apply_from_find')
    expect(page).to have_link href: candidate_interface_apply_from_find_path(providerCode: 'ABC', courseCode: 'XYZ1')
  end

  def and_i_should_see_the_provider_and_course_codes
    expect(page).to have_content 'ABC'
    expect(page).to have_content 'XYZ1'
  end

  def and_i_should_see_the_course_name
    expect(page).to have_content 'Biology (XYZ1)'
  end

  def then_i_should_be_able_to_apply_through_ucas_only
    expect(page).to have_content 'You’ll need to register with UCAS before you can apply.'
  end

  def then_i_should_be_able_to_apply_through_apply
    expect(page).to have_content 'Apply for this course'
  end

  def when_i_visit_the_available_courses_page
    visit candidate_interface_providers_path
  end

  def then_i_should_see_the_available_providers_and_courses
    expect(page).not_to have_content 'Biology'
    expect(page).to have_content 'Potions'
  end

  def given_i_am_on_the_apply_through_apply_page
    visit candidate_interface_apply_from_find_path providerCode: @course_on_apply.provider.code, courseCode: @course_on_apply.code
  end

  def when_i_do_not_make_a_choice_between_ucas_and_apply
    click_button t('continue')
  end

  def then_i_see_an_error
    expect(page).to have_content('Choose if you want to use the new GOV.UK service')
  end

  def when_i_choose_to_apply_through_apply
    choose 'Yes, I want to apply using the new service'

    click_button t('continue')
  end

  def and_i_choose_to_apply_through_ucas
    choose 'No, I want to apply with UCAS'

    click_button t('continue')
  end

  def and_i_confirm_i_am_not_already_signed_up
    choose 'No, I need to create an account'
    click_button t('continue')
  end

  def then_i_see_the_sign_up_page
    expect(page).to have_content 'Create an Apply for teacher training account'
  end

  def and_i_should_see_locations_info_for_an_unsynced_course
    within '[data-qa="locations-table"]' do
      table_data = all('td')

      expect(table_data.first).to have_content 'Main site'
      expect(table_data.last).to have_content 'A'
    end
  end

  def and_i_should_see_locations_info_for_a_synced_course
    within '[data-qa="locations-table"]' do
      table_data = all('td')

      expect(table_data.first).to have_content 'Site for a UCAS-only course'
      expect(table_data.last).to have_content 'OOO'
    end
  end

  def then_i_should_see_an_interstitial_page
    expect(page).to have_content('Apply for this course with UCAS')
  end

  def and_i_should_see_location_details
    pending 'not implemented yet'
  end

  def and_i_should_see_a_link_to_ucas
    pending 'not implemented yet'
  end
end

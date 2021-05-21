require 'rails_helper'

RSpec.feature 'See provider course syncing' do
  include DfESignInHelpers
  include TeacherTrainingPublicAPIHelper

  scenario 'User switches sync courses on Provider' do
    given_i_am_a_support_user
    and_the_last_sync_was_two_hours_ago
    and_a_provider_exists
    and_it_has_courses_in_publish

    when_i_visit_the_providers_page
    then_i_see_that_the_provider_is_not_configured_to_sync_courses

    when_i_click_on_a_provider
    then_i_see_that_course_syncing_is_off

    when_i_click_on_the_enable_course_syncing_button
    then_i_see_that_course_syncing_is_on

    then_i_see_that_a_course_has_been_synced
  end

  def given_i_am_a_support_user
    sign_in_as_support_user
  end

  def and_the_last_sync_was_two_hours_ago
    @updated_since = Time.zone.now - 2.hours
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def and_a_provider_exists
    create :provider, code: 'ABC', name: 'ABC College'
  end

  def and_it_has_courses_in_publish
    stub_teacher_training_api_provider(provider_code: 'ABC', specified_attributes: { code: 'ABC' })

    stub_teacher_training_api_courses(
      provider_code: 'ABC',
      specified_attributes: [
        {
          code: 'ABC1',
          accredited_body_code: nil,
        },
      ],
    )

    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
    )
  end

  def when_i_visit_the_providers_page
    visit support_interface_providers_path
  end

  def then_i_see_that_the_provider_is_not_configured_to_sync_courses
    expect(page).to have_content('ABC College')
  end

  def when_i_click_on_a_provider
    click_link 'ABC College'
    click_link 'Courses'
  end

  def then_i_see_that_course_syncing_is_off
    expect(page).to have_content('There aren’t any courses for this provider because the courses aren’t synced yet')
  end

  def when_i_click_on_the_enable_course_syncing_button
    click_button 'Enable course syncing from Find'
  end

  def then_i_see_that_course_syncing_is_on
    expect(page).not_to have_content('There aren’t any courses for this provider because the courses aren’t synced yet')
  end

  def then_i_see_that_a_course_has_been_synced
    expect(page).to have_content('1 course')
    expect(page).to have_content('0 on DfE Apply')
  end
end

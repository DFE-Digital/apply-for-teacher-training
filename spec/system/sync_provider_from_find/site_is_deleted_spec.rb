require 'rails_helper'

RSpec.describe 'Sync from find' do
  include FindAPIHelper

  scenario 'a site is removed between syncs' do
    given_there_is_a_course_on_find_with_multiple_sites

    when_sync_provider_from_find_is_called
    then_the_correct_course_options_are_created_on_apply

    when_find_says_that_a_site_is_no_longer_listed_for_that_course
    and_sync_provider_from_find_is_called
    then_the_course_option_for_that_site_is_deleted

    given_there_is_a_course_on_find_with_multiple_sites
    and_sync_provider_from_find_has_been_called

    when_find_says_that_a_site_is_no_longer_listed_for_that_course
    and_the_course_option_for_that_site_is_part_of_an_application
    and_sync_provider_from_find_is_called
    then_the_affected_course_option_indicates_that_the_site_is_no_longer_valid
  end

  def given_there_is_a_course_on_find_with_multiple_sites
    stub_find_api_provider_200_with_multiple_sites(provider_name: 'ABC College', provider_code: 'ABC', study_mode: 'full_time')
  end

  def when_sync_provider_from_find_is_called
    SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC', sync_courses: true)
  end

  def then_the_correct_course_options_are_created_on_apply
    @provider = Provider.find_by!(code: 'ABC')

    expect(@provider.courses.first.course_options.count).to eq 2
  end

  def when_find_says_that_a_site_is_no_longer_listed_for_that_course
    stub_find_api_provider_200(provider_name: 'ABC College', provider_code: 'ABC', study_mode: 'full_time')
  end

  def then_the_course_option_for_that_site_is_deleted
    expect(@provider.courses.first.course_options.count).to eq 1
  end

  def and_sync_provider_from_find_has_been_called
    when_sync_provider_from_find_is_called
  end

  def and_the_course_option_for_that_site_is_part_of_an_application
    @course_option = @provider.courses.first.course_options.last
    create(:application_choice, course_option: @course_option)
  end

  def and_sync_provider_from_find_is_called
    when_sync_provider_from_find_is_called
  end

  def then_the_affected_course_option_indicates_that_the_site_is_no_longer_valid
    expect(@provider.courses.first.course_options.count).to eq 2
    expect(@course_option.reload.site_still_valid).to eq false
  end
end

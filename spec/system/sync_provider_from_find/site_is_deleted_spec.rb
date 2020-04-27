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
    and_raven_can_capture_exceptions

    when_find_says_that_a_site_is_no_longer_listed_for_that_course
    and_that_site_is_part_of_an_application
    and_sync_provider_from_find_is_called
    then_the_affected_course_options_invalidated_by_find_attribute_is_set_to_true
    and_raven_captures_an_exception
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

  def and_that_site_is_part_of_an_application
    @course_option = @provider.courses.first.course_options.last
    create(:application_choice, course_option: @course_option)
  end

  def and_sync_provider_from_find_is_called
    when_sync_provider_from_find_is_called
  end

  def and_raven_can_capture_exceptions
    allow(Raven).to receive(:capture_message)
  end

  def then_the_affected_course_options_invalidated_by_find_attribute_is_set_to_true
    expect(@provider.courses.first.course_options.count).to eq 2
    expect(@course_option.reload.invalidated_by_find).to eq true
  end

  def and_raven_captures_an_exception
    expect(Raven).to have_received(:capture_message).with("Course option #{@course_option.id}, which is chosen by candidates, is now invalid.")
  end
end

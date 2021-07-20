require 'rails_helper'

RSpec.describe 'Sync sites' do
  include TeacherTrainingPublicAPIHelper

  scenario 'a site is removed between syncs' do
    given_there_is_a_provider_and_course_on_apply
    and_that_course_on_ttapi_has_multiple_sites

    when_sync_provider_is_called
    then_the_correct_course_options_are_created_on_apply

    when_find_says_that_a_site_is_no_longer_listed_for_that_course
    and_sync_provider_from_find_is_called
    then_the_course_option_for_that_site_is_deleted

    given_that_the_course_on_TTAPI_with_multiple_sites
    and_sync_provider_from_find_has_been_called

    when_find_says_that_a_site_is_no_longer_listed_for_that_course
    and_the_course_option_for_that_site_is_part_of_an_application
    and_sync_provider_from_find_is_called
    then_the_affected_course_option_indicates_that_the_site_is_no_longer_valid
  end

  def given_there_is_a_provider_and_course_on_apply
    @provider = create :provider, code: 'ABC'
    @course = create(:course, code: 'ABC1', provider: @provider, name: 'Secondary')
  end

  def and_that_course_on_ttapi_has_multiple_sites
    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'ABC College',
        },
      ],
    )
    stub_teacher_training_api_courses(
      provider_code: 'ABC',
      specified_attributes: [{
        code: 'ABC1',
      }],
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
      specified_attributes: [{
        code: 'A',
      },
                             {
                               code: 'B',
                             }],
    )
  end
  alias_method :given_that_the_course_on_TTAPI_with_multiple_sites, :and_that_course_on_ttapi_has_multiple_sites

  def when_sync_provider_is_called
    TeacherTrainingPublicAPI::SyncSites.new.perform(@provider.id, stubbed_recruitment_cycle_year, @course.id)
  end

  def then_the_correct_course_options_are_created_on_apply
    expect(@provider.courses.first.course_options.count).to eq 2
  end

  def when_find_says_that_a_site_is_no_longer_listed_for_that_course
    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'ABC College',
        },
      ],
    )

    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               site_code: 'A')
  end

  def then_the_course_option_for_that_site_is_deleted
    expect(@provider.courses.first.course_options.count).to eq 1
  end

  def and_sync_provider_from_find_has_been_called
    when_sync_provider_is_called
  end

  def and_the_course_option_for_that_site_is_part_of_an_application
    @course_option = @provider.courses.first.course_options.last
    create(:application_choice, course_option: @course_option)
  end

  def and_sync_provider_from_find_is_called
    when_sync_provider_is_called
  end

  def then_the_affected_course_option_indicates_that_the_site_is_no_longer_valid
    expect(@provider.courses.first.course_options.count).to eq 2
    expect(@course_option.reload.site_still_valid).to eq false
  end
end

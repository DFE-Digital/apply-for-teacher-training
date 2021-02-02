require 'rails_helper'

RSpec.describe 'Syncing providers', sidekiq: true do
  include FindAPIHelper

  scenario 'Updates course subject codes' do
    given_there_is_an_existing_provider_and_course_in_apply
    and_there_is_a_provider_with_a_course_in_find

    when_the_sync_runs
    then_it_updates_the_course_subject_codes
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_is_an_existing_provider_and_course_in_apply
    @existing_provider = create :provider, code: 'ABC', sync_courses: true
    create :course, code: 'ABC1', provider: @existing_provider, subject_codes: %w[]
  end

  def and_there_is_a_provider_with_a_course_in_find
    stub_find_api_all_providers_200([
      {
        provider_code: 'ABC',
        name: 'ABC College',
      },
    ])

    stub_find_api_provider_200_with_subject_codes(provider_code: 'ABC', provider_name: 'ABC College', course_code: 'ABC1')
  end

  def when_the_sync_runs
    SyncAllFromFind.perform_async
  end

  def then_it_updates_the_course_subject_codes
    course = Course.find_by(code: 'ABC1')

    expect(course.subject_codes).to eq(%w[08])
  end

  def and_it_sets_the_last_synced_timestamp
    expect(FindSyncCheck.last_sync).not_to be_blank
  end
end

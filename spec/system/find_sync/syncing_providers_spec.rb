require 'rails_helper'

RSpec.describe 'Syncing providers', sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  scenario 'Updates course subject codes' do
    given_there_is_an_existing_provider_and_course_in_apply
    and_the_last_sync_was_two_hours_ago
    and_there_is_a_provider_with_a_course_in_find

    when_the_sync_runs
    then_it_updates_the_course_subjects
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_is_an_existing_provider_and_course_in_apply
    @course_uuid = SecureRandom.uuid
    @existing_provider = create :provider, code: 'ABC', sync_courses: true
    create :course, code: 'ABC1', provider: @existing_provider, subjects: %w[], uuid: @course_uuid
  end

  def and_the_last_sync_was_two_hours_ago
    @updated_since = Time.zone.now - 2.hours
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def and_there_is_a_provider_with_a_course_in_find
    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'ABC College',
        },
      ],
      filter_option: { 'filter[updated_since]' => @updated_since },
    )

    stub_teacher_training_api_courses(
      provider_code: 'ABC',
      specified_attributes: [{ code: 'ABC1', accredited_body_code: nil, subject_codes: %w[08], uuid: @course_uuid }],
      filter_option: { 'filter[updated_since]' => @updated_since },
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
    )
  end

  def when_the_sync_runs
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)

    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_updates_the_course_subjects
    course = Course.find_by(code: 'ABC1')

    expect(course.subjects.map(&:code)).to eq(%w[08])
  end

  def and_it_sets_the_last_synced_timestamp
    expect(TeacherTrainingPublicAPI::SyncCheck.last_sync).not_to be_blank
  end
end

require 'rails_helper'

RSpec.describe 'Sync provider', sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  scenario 'Creates and updates providers' do
    given_there_are_2_providers_in_the_teacher_training_api
    and_the_last_sync_was_two_hours_ago
    and_one_of_the_providers_exists_already

    when_the_sync_runs
    then_it_creates_one_provider
    and_it_updates_another
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_providers_in_the_teacher_training_api
    @updated_since = Time.zone.now - 2.hours
    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'ABC',
          name: 'ABC College',
        },
        {
          code: 'DEF',
          name: 'DER College',
        },
      ],
      filter_option: { 'filter[updated_since]' => @updated_since },
    )
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               course_attributes: [{ accredited_body_code: 'ABC' }],
                                               site_code: 'D')
    stub_teacher_training_api_course_with_site(provider_code: 'DEF',
                                               course_code: 'DEF1',
                                               course_attributes: [{ accredited_body_code: 'DEF' }],
                                               site_code: 'E')
  end

  def and_the_last_sync_was_two_hours_ago
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def and_one_of_the_providers_exists_already
    create(:provider, code: 'DEF', name: 'DEF College')
  end

  def when_the_sync_runs
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)

    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_creates_one_provider
    expect(Provider.find_by(code: 'ABC')).not_to be_nil
  end

  def and_it_updates_another
    expect(Provider.find_by(code: 'DEF').name).to eql('DER College')
  end

  def and_it_sets_the_last_synced_timestamp
    expect(TeacherTrainingPublicAPI::SyncCheck.last_sync).not_to be_blank
  end
end

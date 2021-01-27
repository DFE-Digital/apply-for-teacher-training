require 'rails_helper'

RSpec.describe 'Sync sites', sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  scenario 'Creates and updates sites' do
    given_there_are_2_sites_in_the_teacher_training_api
    and_one_of_the_sites_exists_already

    when_the_sync_runs
    then_it_creates_one_site
    and_it_updates_another
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_sites_in_the_teacher_training_api
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
      specified_attributes: [{ code: 'ABC1', accredited_body_code: 'ABC' }],
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
      specified_attributes: [{
        code: 'A',
        name: 'Waterloo Road',
      }, {
        code: 'B',
      }],
    )
  end

  def and_one_of_the_sites_exists_already
    provider = create :provider, code: 'ABC', sync_courses: true
    create(:course, code: 'ABC1', provider: provider)
    create(:site, code: 'A', provider: provider, name: 'Hogwarts School of Witchcraft and Wizardry')
  end

  def when_the_sync_runs
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_creates_one_site
    provider = Provider.find_by(code: 'ABC')
    expect(Site.find_by(code: 'B', provider: provider)).not_to be_nil
  end

  def and_it_updates_another
    provider = Provider.find_by(code: 'ABC')
    site = Site.find_by(code: 'A', provider: provider)
    expect(site.name).to eql('Waterloo Road')
  end

  def and_it_sets_the_last_synced_timestamp
    expect(TeacherTrainingPublicAPI::SyncCheck.last_sync).not_to be_blank
  end
end

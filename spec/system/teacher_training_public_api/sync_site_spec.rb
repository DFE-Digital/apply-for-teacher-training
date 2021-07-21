require 'rails_helper'

RSpec.describe 'Sync sites', sidekiq: true do
  include TeacherTrainingPublicAPIHelper

  scenario 'Creates and updates sites' do
    given_there_are_2_sites_in_the_teacher_training_api
    and_the_last_sync_was_two_hours_ago
    and_one_of_the_sites_exists_already
    and_course_options_with_invalid_sites_exist

    when_the_sync_runs
    then_it_creates_one_site
    and_it_creates_the_corresponding_course_options
    and_it_updates_another
    and_it_correctly_handles_course_options_with_invalid_sites
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_sites_in_the_teacher_training_api
    @course_uuid = SecureRandom.uuid
    @updated_since = Time.zone.now - 2.hours
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)

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
      specified_attributes: [{
        code: 'ABC1',
        accredited_body_code: 'ABC',
        study_mode: 'both',
        uuid: @course_uuid,
      }],
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
      specified_attributes: [{
        code: 'A',
        name: 'Waterloo Road',
      }, {
        code: 'B',
        name: 'St Bernards High School',
        street_address_1: 'Milton Road',
        street_address_2: 'Westcliff on Sea',
        city: nil,
        county: 'Essex',
        postcode: 'SS0 7JS',
        region_code: 'south_east',
        latitude: 51.5371634,
        longitude: 0.69922,
      }],
      vacancy_status: 'part_time_vacancies',
    )
  end

  def and_the_last_sync_was_two_hours_ago
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def and_one_of_the_sites_exists_already
    provider = create :provider, code: 'ABC'
    create(:course, code: 'ABC1', provider: provider, uuid: @course_uuid)
    create(:site, code: 'A', provider: provider, name: 'Hogwarts School of Witchcraft and Wizardry')
  end

  def and_course_options_with_invalid_sites_exist
    provider = Provider.find_by(code: 'ABC')
    course = Course.find_by(code: 'ABC1')

    invalid_site_one = create(:site, code: 'X', provider: provider)
    create(:course_option, course: course, site: invalid_site_one)

    invalid_site_two = create(:site, code: 'Y', provider: provider)
    course_option_two = create(:course_option, course: course, site: invalid_site_two)
    create(:application_choice, course_option: course_option_two)
  end

  def when_the_sync_runs
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_creates_one_site
    site = get_site_by_provider_code('B', 'ABC')
    expect(site).not_to be_nil
    expect(site.name).to eql('St Bernards High School')
    expect(site.address_line1).to eql('Milton Road')
    expect(site.address_line2).to eql('Westcliff on Sea')
    expect(site.address_line3).to be_nil
    expect(site.address_line4).to eql('Essex')
    expect(site.postcode).to eql('SS0 7JS')
    expect(site.region).to eql('south_east')
    expect(site.latitude).to be(51.5371634)
    expect(site.longitude).to be(0.69922)
  end

  def and_it_creates_the_corresponding_course_options
    course = Course.find_by(code: 'ABC1')
    site = get_site_by_provider_code('B', 'ABC')
    full_time_course_option = CourseOption.find_by(site: site, course_id: course.id, study_mode: 'full_time')
    expect(full_time_course_option).not_to be_nil
    expect(full_time_course_option.vacancy_status).to eql('no_vacancies')

    part_time_course_option = CourseOption.find_by(site: site, course_id: course.id, study_mode: 'part_time')
    expect(part_time_course_option).not_to be_nil
    expect(part_time_course_option.vacancy_status).to eql('vacancies')
  end

  def and_it_updates_another
    site = get_site_by_provider_code('A', 'ABC')
    expect(site.name).to eql('Waterloo Road')
  end

  def and_it_correctly_handles_course_options_with_invalid_sites
    invalid_site_1_not_part_of_an_application = get_site_by_provider_code('X', 'ABC')
    invalid_site_2_part_of_an_application = get_site_by_provider_code('Y', 'ABC')

    expect(CourseOption.find_by(site: invalid_site_1_not_part_of_an_application)).to be_nil
    expect(CourseOption.find_by(site: invalid_site_2_part_of_an_application).site_still_valid).to be false
  end

  def and_it_sets_the_last_synced_timestamp
    expect(TeacherTrainingPublicAPI::SyncCheck.last_sync).not_to be_blank
  end

  def get_site_by_provider_code(site_code, provider_code)
    provider = Provider.find_by(code: provider_code)
    Site.find_by(code: site_code, provider: provider)
  end
end

require 'rails_helper'

RSpec.describe 'Sync courses', :sidekiq do
  include TeacherTrainingPublicAPIHelper

  it 'Creates and updates courses' do
    given_there_are_2_courses_in_the_teacher_training_api
    and_the_last_sync_was_two_hours_ago
    and_one_of_the_courses_exists_already

    when_the_sync_runs
    then_it_creates_one_course
    and_it_updates_another
    and_it_sets_the_last_synced_timestamp
  end

  it 'Creates and updates undergraduate courses' do
    given_there_are_2_undergraduate_courses_in_the_teacher_training_api
    and_the_last_sync_was_two_hours_ago
    and_one_of_the_undergraduate_courses_exists_already

    when_the_sync_runs
    then_it_creates_one_undergraduate_course
    and_it_creates_a_corresponding_provider_relationship
    and_it_updates_another
    and_it_sets_the_last_synced_timestamp
  end

  def given_there_are_2_courses_in_the_teacher_training_api
    @updated_since = 2.hours.ago
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)
    @course_uuid = SecureRandom.uuid

    stub_teacher_training_api_providers(
      specified_attributes: [
        {
          code: 'aBc', # Mixed case to verify case insensitivity
          name: 'ABC College',
        },
      ],
      filter_option: { 'filter[updated_since]' => @updated_since },
    )
    stub_teacher_training_api_courses(
      provider_code: 'ABC',
      specified_attributes: [
        {
          code: 'ABC1',
          name: 'Primary',
          level: 'primary',
          study_mode: 'full_time',
          summary: 'PGCE with QTS full time',
          start_date: 'September 2021',
          course_length: 'OneYear',
          findable: true,
          funding_type: 'fee',
          program_type: 'school_direct_training_programme',
          age_maximum: 11,
          age_minimum: 3,
          state: 'published',
          qualifications: %w[qts pgce],
          accredited_body_code: '',
          application_status: 'open',
          uuid: @course_uuid,
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: false,
        },
        {
          code: 'ABC2',
          name: 'Primary',
          level: 'primary',
          study_mode: 'full_time',
          summary: 'PGCE with QTS full time',
          start_date: 'September 2021',
          course_length: 'OneYear',
          findable: true,
          funding_type: 'fee',
          program_type: 'school_direct_training_programme',
          age_maximum: 11,
          age_minimum: 3,
          state: 'published',
          qualifications: %w[qts pgce],
          application_status: 'closed',
          accredited_body_code: 'DEF',
          can_sponsor_skilled_worker_visa: true,
          can_sponsor_student_visa: true,
        },
      ],
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC2',
    )
  end

  def given_there_are_2_undergraduate_courses_in_the_teacher_training_api
    @updated_since = 2.hours.ago
    sync_subjects_service = instance_double(TeacherTrainingPublicAPI::SyncSubjects, perform: nil)
    allow(TeacherTrainingPublicAPI::SyncSubjects).to receive(:new).and_return(sync_subjects_service)
    @course_uuid = SecureRandom.uuid

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
      specified_attributes: [
        {
          code: 'ABC1',
          name: 'Primary',
          level: 'primary',
          study_mode: 'full_time',
          summary: 'Teacher degree apprenticeship with QTS',
          start_date: 'September 2025',
          course_length: '4 years',
          findable: true,
          funding_type: 'fee',
          program_type: 'teacher_degree_apprenticeship',
          age_maximum: 11,
          age_minimum: 3,
          state: 'published',
          qualifications: %w[qts undergraduate_degree],
          accredited_body_code: '',
          application_status: 'open',
          uuid: @course_uuid,
          can_sponsor_skilled_worker_visa: false,
          can_sponsor_student_visa: false,
        },
        {
          code: 'ABC2',
          name: 'Primary',
          level: 'primary',
          study_mode: 'full_time',
          summary: 'Teacher degree apprenticeship with QTS',
          start_date: 'September 2025',
          course_length: '4 years',
          findable: true,
          funding_type: 'fee',
          program_type: 'teacher_degree_apprenticeship',
          age_maximum: 11,
          age_minimum: 3,
          state: 'published',
          qualifications: %w[qts undergraduate_degree],
          application_status: 'closed',
          accredited_body_code: 'DEF',
          can_sponsor_skilled_worker_visa: true,
          can_sponsor_student_visa: true,
        },
      ],
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC1',
    )
    stub_teacher_training_api_sites(
      provider_code: 'ABC',
      course_code: 'ABC2',
    )
  end

  def and_the_last_sync_was_two_hours_ago
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def and_one_of_the_courses_exists_already
    provider = create(:provider, code: 'ABC')
    create(:provider, code: 'DEF')
    create(:course, code: 'ABC1', provider:, name: 'Secondary', uuid: @course_uuid)
  end

  def and_one_of_the_undergraduate_courses_exists_already
    provider = create(:provider, code: 'ABC')
    create(:provider, code: 'DEF')
    create(:course, :teacher_degree_apprenticeship, code: 'ABC1', provider:, name: 'Secondary', uuid: @course_uuid)
  end

  def when_the_sync_runs
    TeacherTrainingPublicAPI::SyncAllProvidersAndCoursesWorker.perform_async
  end

  def then_it_creates_one_course
    course = Course.find_by(code: 'ABC2')
    expect(course).not_to be_nil
    expect(course.can_sponsor_skilled_worker_visa).to be true
    expect(course.can_sponsor_student_visa).to be true
    expect(course.application_status).to eq 'closed'
  end

  def then_it_creates_one_undergraduate_course
    course = Course.find_by(code: 'ABC2')
    expect(course).not_to be_nil
    expect(course.program_type).to eq 'teacher_degree_apprenticeship'
    expect(course.qualifications).to eq %w[qts undergraduate_degree]
    expect(course.course_length).to eq '4 years'
  end

  def and_it_creates_a_corresponding_provider_relationship
    training_provider = Provider.find_by(code: 'ABC')
    ratifying_provider = Provider.find_by(code: 'DEF')
    expect(ProviderRelationshipPermissions.find_by(training_provider:, ratifying_provider:)).not_to be_nil
  end

  def and_it_updates_another
    course = Course.find_by(code: 'ABC1')
    expect(course.provider.code).to eq('ABC')
    expect(course.name).to eql('Primary')
    expect(course.age_range).to eql('3 to 11')
    expect(course.withdrawn).to be false
    expect(course.can_sponsor_skilled_worker_visa).to be false
    expect(course.can_sponsor_student_visa).to be false
    expect(course.application_status).to eq 'open'
  end

  def and_it_sets_the_last_synced_timestamp
    expect(TeacherTrainingPublicAPI::SyncCheck.last_sync).not_to be_blank
  end
end

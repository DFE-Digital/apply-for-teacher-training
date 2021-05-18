require 'rails_helper'

RSpec.describe 'Sync from Teacher Training API' do
  include TeacherTrainingPublicAPIHelper

  scenario 'a courses study mode changes between syncs' do
    given_there_is_a_full_time_course_on_the_teacher_training_api
    and_the_last_sync_was_two_hours_ago

    when_sync_provider_is_called
    then_the_correct_course_option_is_created_on_apply

    given_the_course_becomes_full_time_and_part_time

    when_sync_provider_is_called
    then_a_part_time_course_option_is_created_with_vacancies

    given_the_course_returns_to_full_time

    when_sync_provider_is_called
    then_the_part_time_course_option_is_set_to_no_vacancies
  end

  def given_there_is_a_full_time_course_on_the_teacher_training_api
    @updated_since = Time.zone.now - 2.hours
    @provider = create :provider, code: 'ABC', sync_courses: true
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since },
                                               site_code: 'A',
                                               vacancy_status: 'full_time_vacancies')
  end

  def and_the_last_sync_was_two_hours_ago
    allow(TeacherTrainingPublicAPI::SyncCheck).to receive(:updated_since).and_return(@updated_since)
  end

  def when_sync_provider_is_called
    provider_from_api = fake_api_provider(code: 'ABC')

    TeacherTrainingPublicAPI::SyncProvider.new(
      provider_from_api: provider_from_api,
      recruitment_cycle_year: RecruitmentCycle.current_year,
    ).call
  end

  def then_the_correct_course_option_is_created_on_apply
    expect(Provider.find_by(code: 'ABC')).not_to be_nil

    @course = Course.find_by(code: 'ABC1')
    expect(@course).not_to be_nil
    expect(@course.course_options.count).to eq 1
    expect(@course.course_options.first.study_mode).to eq 'full_time'
    expect(@course.course_options.first.vacancy_status).to eq 'vacancies'
  end

  def given_the_course_becomes_full_time_and_part_time
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               course_attributes: [{ accredited_body_code: nil, study_mode: 'both' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since },
                                               site_code: 'A',
                                               vacancy_status: 'both_full_time_and_part_time_vacancies')
  end

  def then_a_part_time_course_option_is_created_with_vacancies
    expect(@course.course_options.count).to eq 2
    expect(@course.course_options.last.study_mode).to eq 'part_time'
    expect(@course.course_options.last.vacancy_status).to eq 'vacancies'
  end

  def given_the_course_returns_to_full_time
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               course_attributes: [{ accredited_body_code: nil, study_mode: 'full_time' }],
                                               filter_option: { 'filter[updated_since]' => @updated_since },
                                               site_code: 'A',
                                               vacancy_status: 'full_time_vacancies')
  end

  def then_the_part_time_course_option_is_set_to_no_vacancies
    expect(@course.course_options.count).to eq 2
    expect(@course.course_options.last.study_mode).to eq 'part_time'
    expect(@course.course_options.last.vacancy_status).to eq 'no_vacancies'
  end
end

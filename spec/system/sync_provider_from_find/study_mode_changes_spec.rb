require 'rails_helper'

RSpec.describe 'Sync from find' do
  include FindAPIHelper

  scenario 'a courses study mode changes between syncs' do
    given_there_is_a_full_time_course_on_find

    when_sync_provider_from_find_is_called
    then_the_correct_course_option_is_created_on_apply

    given_the_course_becomes_full_time_and_part_time

    when_sync_provider_from_find_is_called
    then_a_part_time_course_option_is_created_with_vacancies

    given_the_course_returns_to_full_time

    when_sync_provider_from_find_is_called
    then_the_part_time_course_option_is_set_to_no_vacancies
  end

  def given_there_is_a_full_time_course_on_find
    stub_find_api_provider_200(provider_name: 'ABC College', provider_code: 'ABC', study_mode: 'full_time')
  end

  def when_sync_provider_from_find_is_called
    SyncProviderFromFind.call(provider_name: 'ABC College', provider_code: 'ABC', sync_courses: true)
  end

  def then_the_correct_course_option_is_created_on_apply
    @provider = Provider.find_by!(code: 'ABC')

    expect(@provider.courses.first.course_options.count).to eq 1
    expect(@provider.courses.first.course_options.first.study_mode).to eq 'full_time'
    expect(@provider.courses.first.course_options.first.vacancy_status).to eq 'vacancies'
  end

  def given_the_course_becomes_full_time_and_part_time
    stub_find_api_provider_200(provider_name: 'ABC College', provider_code: 'ABC', study_mode: 'full_time_or_part_time', vac_status: 'both_full_time_and_part_time_vacancies')
  end

  def then_a_part_time_course_option_is_created_with_vacancies
    expect(@provider.courses.first.course_options.count).to eq 2
    expect(@provider.courses.first.course_options.last.study_mode).to eq 'part_time'
    expect(@provider.courses.first.course_options.last.vacancy_status).to eq 'vacancies'
  end

  def given_the_course_returns_to_full_time
    stub_find_api_provider_200(provider_name: 'ABC College', provider_code: 'ABC', study_mode: 'full_time')
  end

  def then_the_part_time_course_option_is_set_to_no_vacancies
    expect(@provider.courses.first.course_options.count).to eq 2
    expect(@provider.courses.first.course_options.last.study_mode).to eq 'part_time'
    expect(@provider.courses.first.course_options.last.vacancy_status).to eq 'no_vacancies'
  end
end

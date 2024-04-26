require 'rails_helper'

RSpec.feature 'Sync sites' do
  include TeacherTrainingPublicAPIHelper

  it 'a site has no vacancies and is not set to vacancies by the sync' do
    given_there_is_a_provider_and_has_two_courses_on_apply
    and_that_both_courses_exists_on_the_ttapi

    when_sync_provider_is_called_with_an_open_course
    then_the_site_has_vacancies

    when_sync_provider_is_called_with_a_closed_course
    then_the_site_has_no_vacancies
  end

  def given_there_is_a_provider_and_has_two_courses_on_apply
    @site_uuid = SecureRandom.uuid
    @provider = create(:provider, code: 'ABC')
    @site = create(:site, code: 'A', provider: @provider, uuid: @site_uuid)
    @course = create(:course, code: 'ABC1', provider: @provider, name: 'Secondary')

    @second_course = create(:course, code: 'ABC2', provider: @provider, name: 'Secondary')
  end

  def and_that_both_courses_exists_on_the_ttapi
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               site_code: 'A',
                                               site_attributes: [{
                                                 uuid: @site_uuid,
                                               }])

    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC2',
                                               site_code: 'A',
                                               site_attributes: [{
                                                 uuid: @site_uuid,
                                               }])
  end

  def when_sync_provider_is_called_with_an_open_course
    TeacherTrainingPublicAPI::SyncSites.new.perform(
      @provider.id,
      stubbed_recruitment_cycle_year,
      @course.id,
      'open',
    )
  end

  def then_the_site_has_vacancies
    expect(@course.reload.course_options.count).to eq 1
    expect(@course.reload.course_options.first.vacancy_status).to eq 'vacancies'
  end

  def when_sync_provider_is_called_with_a_closed_course
    TeacherTrainingPublicAPI::SyncSites.new.perform(
      @provider.id,
      stubbed_recruitment_cycle_year,
      @second_course.id,
      'closed',
    )
  end

  def then_the_site_has_no_vacancies
    expect(@second_course.reload.course_options.count).to eq 1
    expect(@second_course.reload.course_options.first.vacancy_status).to eq 'no_vacancies'
  end
end

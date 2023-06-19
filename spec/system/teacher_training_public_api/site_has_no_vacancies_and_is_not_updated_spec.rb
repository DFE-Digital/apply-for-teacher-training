require 'rails_helper'

RSpec.feature 'Sync sites' do
  include TeacherTrainingPublicAPIHelper

  it 'a site has no vacancies and is not set to vacancies by the sync' do
    given_there_is_a_provider_and_course_on_apply
    and_that_course_exists_on_the_ttapi

    when_sync_provider_is_called
    then_the_vancacy_attribute_does_not_change
  end

  def given_there_is_a_provider_and_course_on_apply
    @site_uuid = SecureRandom.uuid
    @provider = create(:provider, code: 'ABC')
    @site = create(:site, code: 'A', provider: @provider, uuid: @site_uuid)
    @course = create(:course, code: 'ABC1', provider: @provider, name: 'Secondary')
    @course_option = create(:course_option, :no_vacancies, course: @course, site: @site)
  end

  def and_that_course_exists_on_the_ttapi
    stub_teacher_training_api_course_with_site(provider_code: 'ABC',
                                               course_code: 'ABC1',
                                               site_code: 'A',
                                               site_attributes: [{
                                                 uuid: @site_uuid,
                                               }])
  end

  def when_sync_provider_is_called
    TeacherTrainingPublicAPI::SyncSites.new.perform(@provider.id, stubbed_recruitment_cycle_year, @course.id)
  end

  def then_the_vancacy_attribute_does_not_change
    expect(@course.reload.course_options.count).to eq 1
    expect(@course.reload.course_options.first.vacancy_status).to eq 'no_vacancies'
  end
end

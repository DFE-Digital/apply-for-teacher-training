require 'rails_helper'

RSpec.describe DataMigrations::BackfillTempSites do
  include TeacherTrainingPublicAPIHelper

  let(:uuid) { Faker::Internet.uuid }
  let(:other_uuid) { Faker::Internet.uuid }
  let(:provider) { create(:provider, code: '1YD') }

  before do
    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2019)
    stub_teacher_training_api_course_with_site(provider_code: provider.code, recruitment_cycle_year: 2019, course_code: 'WA', site_code: 'A', site_attributes: [{ uuid: uuid }])

    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2020)
    stub_teacher_training_api_course_with_site(provider_code: provider.code, recruitment_cycle_year: 2020, course_code: 'WB', site_code: 'B', site_attributes: [{ uuid: uuid }])

    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2021)
    stub_teacher_training_api_course_with_site(provider_code: provider.code, recruitment_cycle_year: 2021, course_code: 'WC', site_code: 'A', site_attributes: [{ uuid: other_uuid }])

    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2022)
    stub_teacher_training_api_course_with_site(provider_code: provider.code, recruitment_cycle_year: 2022, course_code: 'WD', site_code: 'A', site_attributes: [{ uuid: other_uuid }])
  end

  it 'backfills temp site for each recruitment cycle' do
    expect { described_class.new.change }.to change { TempSite.count }.by(2)
  end
end

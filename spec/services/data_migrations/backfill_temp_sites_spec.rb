require 'rails_helper'

RSpec.describe DataMigrations::BackfillTempSites do
  include TeacherTrainingPublicAPIHelper

  let(:uuid) { Faker::Internet.uuid }
  let(:other_uuid) { Faker::Internet.uuid }
  let(:provider) { create(:provider, code: '1YD') }

  subject(:run_job) { described_class.new.change }

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

  context 'when there is a site with no UUID' do
    let(:other_uuid) { nil }
    let(:uuid) { nil }

    it 'generates the uuid and sets the flag' do
      run_job
      TempSite.all.each do |site|
        expect(site.uuid).to be_present
        expect(site).to be_uuid_generated_by_apply
      end
    end

    it 'backfills temp site for each recruitment cycle' do
      expect { run_job }.to change { TempSite.count }.by(4)
    end
  end

  context 'when there is a site with a UUID' do
    it 'assigns the uuid and does not set the flag' do
      run_job
      TempSite.all.each do |site|
        expect(site.uuid).to be_present
        expect(site).not_to be_uuid_generated_by_apply
      end
    end

    it 'backfills temp site for each recruitment cycle' do
      expect { run_job }.to change { TempSite.count }.by(2)
    end
  end

  context 'sites existing in a future recruitment cycle' do
    before do
      stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: CycleTimetable.next_year)
      stub_teacher_training_api_course_with_site(provider_code: provider.code, recruitment_cycle_year: CycleTimetable.next_year, course_code: 'WD', site_code: 'FUTURE', site_attributes: [{ uuid: other_uuid }])
    end

    it 'does not create temp sites for future recruitment cycles' do
      run_job
      expect(TempSite.find_by(code: 'FUTURE')).to be_nil
    end
  end
end

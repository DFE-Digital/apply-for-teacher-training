require 'rails_helper'

RSpec.describe MigrateTempSitesForProvidersWorker do
  include TeacherTrainingPublicAPIHelper

  let(:uuid) { Faker::Internet.uuid }
  let(:other_uuid) { Faker::Internet.uuid }
  let(:provider) { create(:provider, code: '1YD') }
  let(:course) { create(:course, provider: provider, code: 'WA') }
  let(:second_course) { create(:course, provider: provider, code: 'WB') }
  let(:site) { create(:site, provider: provider, code: 'A', uuid: uuid) }
  let(:second_site) { create(:site, provider: provider, code: 'B', uuid: other_uuid) }
  let!(:course_option_1) { create(:course_option, site: site, course: course, study_mode: 'full_time') }
  let!(:course_option_2) { create(:course_option, site: second_site, course: second_course, study_mode: 'part_time') }

  subject(:run_job) { described_class.new.perform(provider.id, CycleTimetable.current_year) }

  before do
    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: CycleTimetable.current_year)
    stub_teacher_training_api_course_with_site(
      provider_code: provider.code,
      recruitment_cycle_year: CycleTimetable.current_year,
      course_code: course.code,
      site_code: site.code,
      site_attributes: [{ uuid: uuid }],
    )
    stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: CycleTimetable.current_year)
    stub_teacher_training_api_course_with_site(
      provider_code: provider.code,
      recruitment_cycle_year: CycleTimetable.current_year,
      course_code: second_course.code,
      site_code: second_site.code,
      site_attributes: [{ uuid: uuid }],
    )
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

    it 'attaches temp site to course option' do
      run_job
      expect(course_option_1.reload.site).to be_present
      expect(course_option_2.reload.site).to be_present
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
  end

  context 'when a site exists across multiple recruitment cycle years' do
    before do
      stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2021)
      stub_teacher_training_api_course_with_site(
        provider_code: provider.code,
        recruitment_cycle_year: 2021,
        course_code: 'WA',
        site_code: site.code,
        site_attributes: [{ uuid: uuid }],
      )
      stub_teacher_training_api_provider(provider_code: provider.code, recruitment_cycle_year: 2022)
      stub_teacher_training_api_course_with_site(
        provider_code: provider.code,
        recruitment_cycle_year: 2022,
        course_code: 'WA',
        site_code: site.code,
        site_attributes: [{ uuid: other_uuid }],
      )
    end

    it 'creates separate temp sites' do
      expect {
        described_class.new.perform(provider.id, 2021)
        described_class.new.perform(provider.id, 2022)
      }.to change { TempSite.count }.by(2)
    end
  end
end

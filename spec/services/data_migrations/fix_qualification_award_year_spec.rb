require 'rails_helper'

RSpec.describe DataMigrations::FixQualificationAwardYear do
  let(:application_form) { create(:application_form, :minimum_info, recruitment_cycle_year: RecruitmentCycle.current_year) }

  context "when qualification award year has the pattern 'YYYY - YYYY'" do
    it 'updates the application qualification with the second year' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020 - 2021', application_form: application_form)
      other_qualification = create(:other_qualification, award_year: '2020 - 2021', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2021')
      expect(other_qualification.award_year).to eq('2021')
    end
  end

  context "when qualification award year has the pattern 'YYYY / YYYY'" do
    it 'updates the application qualification with the second year' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020 / 2021', application_form: application_form)
      other_qualification = create(:other_qualification, award_year: '2020 / 2021', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2021')
      expect(other_qualification.award_year).to eq('2021')
    end
  end

  context "when qualification award year has the pattern 'YYYY/YYYY'" do
    it 'updates the application qualification with the second year' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020/2021', application_form: application_form)
      other_qualification = create(:other_qualification, award_year: '2020/2021', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2021')
      expect(other_qualification.award_year).to eq('2021')
    end
  end

  context "when qualification award year has the pattern 'YYYY/YY'" do
    it 'updates the application qualification with the correctly formatted second year' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020/21', application_form: application_form)
      other_qualification = create(:other_qualification, award_year: '2020/21', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2021')
      expect(other_qualification.award_year).to eq('2021')
    end
  end

  context "when qualification award year has the pattern 'YYYY and YYYY'" do
    it 'updates the application qualification with the second year' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020 and 2021', application_form: application_form)
      other_qualification = create(:other_qualification, award_year: '2020 and 2021', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2021')
      expect(other_qualification.award_year).to eq('2021')
    end
  end

  context "when qualification award year has the correct pattern i.e. 'YEAR'" do
    it 'leaves the award year untouched' do
      gcse_qualification = create(:gcse_qualification, award_year: '2020', application_form: application_form)
      other_qualification = create(:gcse_qualification, award_year: '2020', application_form: application_form)

      described_class.new.change
      gcse_qualification.reload
      other_qualification.reload

      expect(gcse_qualification.award_year).to eq('2020')
      expect(other_qualification.award_year).to eq('2020')
    end
  end
end

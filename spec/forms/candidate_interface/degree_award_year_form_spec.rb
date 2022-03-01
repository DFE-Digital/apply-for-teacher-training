require 'rails_helper'

RSpec.describe CandidateInterface::DegreeAwardYearForm, type: :model do
  describe 'award year' do
    context 'year validations' do
      let(:model) do
        described_class.new(award_year: award_year)
      end

      include_examples 'year validations', :award_year
    end

    it 'is invalid if they provide a award year that is two years in the past' do
      degree = build_stubbed(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: true,
        application_form: build_stubbed(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year),
      )

      degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.previous_year - 1)

      degree_award_year_form.validate(:award_year)

      expect(degree_award_year_form.errors.full_messages_for(:award_year)).to eq(
        ['Award year Enter a year that is the current year or a year in the future'],
      )
    end

    it 'is valid if they provide the previous recruitment cycle year' do
      degree = build_stubbed(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: true,
        application_form: build_stubbed(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year),
      )

      degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.previous_year)

      degree_award_year_form.validate(:award_year)

      expect(degree_award_year_form.errors.full_messages_for(:award_year)).to be_empty
    end

    it 'is invalid if they do not graduate before the end of the current cycle' do
      degree = build_stubbed(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: true,
        application_form: build_stubbed(:application_form, recruitment_cycle_year: RecruitmentCycle.current_year),
      )

      degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.next_year)

      degree_award_year_form.validate(:award_year)

      expect(degree_award_year_form.errors.full_messages_for(:award_year)).to eq(
        ['Award year The date you graduate must be before the start of your teacher training'],
      )
    end

    context 'carried over applications' do
      it 'is valid if the award year is in the same cycle as the application form' do
        degree = build_stubbed(
          :degree_qualification,
          qualification_type: 'BSc',
          predicted_grade: true,
          application_form: build_stubbed(:application_form, recruitment_cycle_year: RecruitmentCycle.next_year),
        )

        degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.next_year)

        expect(degree_award_year_form.valid?).to be true
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::DegreeYearForm, type: :model do
  describe 'award year' do
    context 'year validations' do
      let(:model) do
        described_class.new(award_year: award_year)
      end

      include_examples 'year validations', :award_year
    end

    it 'is invalid if the award year is more than ten years into the future' do
      degree = build(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: false,
        start_year: RecruitmentCycle.current_year,
      )

      degree_form = described_class.new(degree: degree, award_year: RecruitmentCycle.current_year + 11)

      degree_form.validate(:award_year)

      expect(degree_form.errors.full_messages_for(:award_year)).to eq(
        ["Award year Enter a year before #{RecruitmentCycle.current_year + 10}"],
      )
    end

    it 'is invalid if the degree is incomplete and the award year is in the past' do
      Timecop.freeze(Time.zone.local(2012, 1, 1)) do
        degree = build(
          :degree_qualification,
          qualification_type: 'BSc',
          predicted_grade: true,
        )

        degree_form = described_class.new(degree: degree, start_year: '2008', award_year: '2009')

        degree_form.validate(:award_year)

        expect(degree_form.errors.full_messages_for(:award_year)).to eq(
          ['Award year Enter a year that is in the future'],
        )
      end
    end
  end

  describe 'start year' do
    it 'is invalid if greater than the award year' do
      degree = build(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: false,
      )

      degree_form = described_class.new(degree: degree, start_year: '2009', award_year: '2008')
      error_message = t('activemodel.errors.models.candidate_interface/degree_year_form.attributes.start_year.greater_than_award_year')

      degree_form.validate(:start_year)

      expect(degree_form.errors.full_messages_for(:start_year)).to eq(
        ["Start year #{error_message}"],
      )
    end
  end
end

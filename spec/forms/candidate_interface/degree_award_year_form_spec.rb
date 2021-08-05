require 'rails_helper'

RSpec.describe CandidateInterface::DegreeAwardYearForm, type: :model do
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

      degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.current_year + 11)

      degree_award_year_form.validate(:award_year)

      expect(degree_award_year_form.errors.full_messages_for(:award_year)).to eq(
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

        degree_award_year_form = described_class.new(degree: degree, award_year: '2009')

        degree_award_year_form.validate(:award_year)

        expect(degree_award_year_form.errors.full_messages_for(:award_year)).to eq(
          ['Award year Enter a year that is in the future'],
        )
      end
    end

    it 'is invalid if the degree is incomplete and the award year is 2 or more years into the future' do
      degree = build(
        :degree_qualification,
        qualification_type: 'BSc',
        predicted_grade: true,
      )

      degree_award_year_form = described_class.new(degree: degree, award_year: RecruitmentCycle.next_year)

      degree_award_year_form.validate(:award_year)

      expect(degree_award_year_form.errors.full_messages_for(:award_year)).to eq(
        ['Award year The date you graduate must be before the start of your teacher training'],
      )
    end
  end
end

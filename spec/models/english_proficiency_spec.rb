require 'rails_helper'

RSpec.describe EnglishProficiency do
  describe 'associations' do
    it { is_expected.to belong_to(:application_form) }
    it { is_expected.to belong_to(:efl_qualification).optional.dependent(:destroy) }
  end

  describe 'enums' do
    subject(:english_proficiency) { build(:english_proficiency) }

    it {
      expect(english_proficiency).to(
        define_enum_for(:qualification_status).with_values(
          has_qualification: 'has_qualification',
          no_qualification: 'no_qualification',
          qualification_not_needed: 'qualification_not_needed',
          degree_taught_in_english: 'degree_taught_in_english',
        ).backed_by_column_of_type(:string),
      )
    }
  end

  describe 'scopes' do
    describe '.draft' do
      let(:published_english_proficiency) { create(:english_proficiency) }
      let(:draft_english_proficiency) { create(:english_proficiency, :draft) }

      before do
        published_english_proficiency
        draft_english_proficiency
      end

      it 'returns only draft english proficiencies' do
        expect(described_class.draft).to contain_exactly(draft_english_proficiency)
      end
    end
  end

  describe '#formatted_qualification_description' do
    it 'returns nothing if no efl_qualification is present' do
      english_proficiency = build(:english_proficiency)
      expect(english_proficiency.formatted_qualification_description).to be_blank
    end

    it 'returns a formatted string description of various kinds of efl_qualification' do
      english_proficiency = build(:english_proficiency)
      expected_results = [
        {
          qualification: build(:ielts_qualification, band_score: '3.5', award_year: '1999', trf_number: '123456'),
          description: 'Name: IELTS, Grade: 3.5, Awarded: 1999, Reference: 123456',
        },
        {
          qualification: build(:toefl_qualification, total_score: 30, award_year: '2000', registration_number: '654321'),
          description: 'Name: TOEFL, Grade: 30, Awarded: 2000, Reference: 654321',
        },
        {
          qualification: build(:other_efl_qualification, name: 'Anglais for Dummies', grade: 'A+++', award_year: '2001'),
          description: 'Name: Anglais for Dummies, Grade: A+++, Awarded: 2001',
        },
      ]

      expected_results.each do |expected_result|
        english_proficiency.efl_qualification = expected_result[:qualification]
        expect(english_proficiency.formatted_qualification_description).to(
          eq(expected_result[:description]),
        )
      end
    end
  end

  describe '#qualification_statuses' do
    let(:english_proficiency) do
      create(
        :english_proficiency,
        has_qualification:,
        no_qualification:,
        degree_taught_in_english:,
        qualification_not_needed:,
      )
    end
    let(:has_qualification) { true }
    let(:no_qualification) { false }
    let(:degree_taught_in_english) { true }
    let(:qualification_not_needed) { true }

    context 'when many qualifications statuses are true' do
      it 'returns the true qualification status attributes as an array' do
        expect(
          english_proficiency.qualification_statuses,
        ).to contain_exactly('has_qualification', 'qualification_not_needed', 'degree_taught_in_english')
      end
    end

    context 'when one qualifications statuses are true' do
      let(:has_qualification) { false }
      let(:no_qualification) { true }
      let(:degree_taught_in_english) { false }
      let(:qualification_not_needed) { false }

      it 'returns the true qualification status attribute as an array' do
        expect(
          english_proficiency.qualification_statuses,
        ).to contain_exactly('no_qualification')
      end
    end
  end
end

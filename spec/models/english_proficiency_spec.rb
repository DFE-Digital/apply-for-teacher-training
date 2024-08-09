require 'rails_helper'

RSpec.describe EnglishProficiency do
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
end

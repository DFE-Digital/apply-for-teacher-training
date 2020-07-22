require 'rails_helper'

RSpec.describe CandidateInterface::GetNationalitiesFormHash do
  describe '#call' do
    let(:data) do
      {
        first_nationality: 'British',
        second_nationality: 'Irish',
        third_nationality: 'Welsh',
        fourth_nationality: 'Northern Irish',
        fifth_nationality: 'Scottish',
      }
    end

    let(:expected_hash) do
      {
        british: data[:first_nationality],
        irish: data[:second_nationality],
        other: 'other',
        other_nationality1: data[:third_nationality],
        other_nationality2: data[:fourth_nationality],
        other_nationality3: data[:fifth_nationality],
      }
    end

    it 'sets the course_is_on_apply and course_on_find attributes to true' do
      application_form = ApplicationForm.new(data)
      expect(described_class.new(application_form: application_form).call).to eq expected_hash
    end
  end
end

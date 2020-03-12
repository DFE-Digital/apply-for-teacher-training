require 'rails_helper'

RSpec.describe DisplayCourseLength do
  context 'when OneYear' do
    let(:course_length) { 'OneYear' }

    it 'returns "1 year"' do
      expect(described_class.call(course_length: course_length)).to eq '1 year'
    end
  end

  context 'when TwoYears' do
    let(:course_length) { 'TwoYears' }

    it 'returns "Up to 2 years"' do
      expect(described_class.call(course_length: course_length)).to eq 'Up to 2 years'
    end
  end

  context 'when another value' do
    let(:course_length) { 'Any other amount' }

    it 'returns that value' do
      expect(described_class.call(course_length: course_length)).to eq 'Any other amount'
    end
  end
end

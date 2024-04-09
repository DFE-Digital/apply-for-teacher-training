require 'rails_helper'

RSpec.describe QualificationValueHelper do
  describe '#qualification_text' do
    let(:course_option) { build_stubbed(:course_option, course: @course) }

    context 'when there are multiple values' do
      it 'capitalises and concatenates the values' do
        @course = build_stubbed(:course, qualifications: %w[qts pgce])

        expect(qualification_text(course_option)).to eq 'QTS with PGCE'
      end
    end

    context 'when there is a single value' do
      it 'capitalises the value' do
        @course = build_stubbed(:course, qualifications: %w[qts])

        expect(qualification_text(course_option)).to eq 'QTS'
      end
    end

    context 'when there is no value' do
      it 'returns nil' do
        @course = build_stubbed(:course, qualifications: nil)

        expect(qualification_text(course_option)).to be_nil
      end
    end
  end
end

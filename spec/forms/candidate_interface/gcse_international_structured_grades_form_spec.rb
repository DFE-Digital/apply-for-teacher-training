require 'rails_helper'

RSpec.describe CandidateInterface::GcseInternationalStructuredGradesForm do
  describe 'validations' do
    context 'when grade is blank' do
      subject(:form) { described_class.new(grade: nil) }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:grade]).to include('Select a grade')
      end
    end

    context 'when a structured grade is selected' do
      subject(:form) do
        described_class.new(
          grade: 'A',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end

    context 'when other is selected and no grade is entered' do
      subject(:form) do
        described_class.new(
          grade: 'other',
          non_structured_grade: nil,
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:non_structured_grade]).to include('Enter a grade')
      end
    end

    context 'when other is selected and grade is too long' do
      subject(:form) do
        described_class.new(
          grade: 'other',
          non_structured_grade: 'A very long grade',
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:non_structured_grade]).to include('Grade must be 10 characters or fewer')
      end
    end

    context 'when other is selected and grade is valid' do
      subject(:form) do
        described_class.new(
          grade: 'other',
          non_structured_grade: 'My grade',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end
  end
end

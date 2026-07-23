require 'rails_helper'

RSpec.describe CandidateInterface::GcseInternationalGradeSchemasForm do
  describe 'validations' do
    context 'when schema_id is blank' do
      subject(:form) { described_class.new(schema_id: nil) }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:schema_id]).to include('Select a type')
      end
    end

    context 'when a schema is selected' do
      subject(:form) do
        described_class.new(
          schema_id: 'cf71151e-df9d-465b-ad9f-d129764a0165',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end

    context 'when other is selected and no grade is entered' do
      subject(:form) do
        described_class.new(
          schema_id: 'other',
          grade: nil,
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:grade]).to include('Enter a grade')
      end
    end

    context 'when other is selected and grade is too long' do
      subject(:form) do
        described_class.new(
          schema_id: 'other',
          grade: 'A very long grade that has gone beyond 20 chars',
        )
      end

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:grade]).to include('Grade must be 20 characters or fewer')
      end
    end

    context 'when other is selected and grade is valid' do
      subject(:form) do
        described_class.new(
          schema_id: 'other',
          grade: 'My grade',
        )
      end

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end
  end
end

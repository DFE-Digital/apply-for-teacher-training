require 'rails_helper'

RSpec.describe CandidateInterface::GcseInternationalEvidenceForm do
  describe 'validations' do
    context 'when evidence is blank' do
      subject(:form) { described_class.new(evidence: nil, subject: 'maths') }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:evidence]).to include('Enter evidence that your maths skills are at GCSE grade 4 (C) or above')
      end
    end

    context 'when evidence is too long' do
      subject(:form) { described_class.new(evidence: 'A' * 501, subject: 'maths') }

      it 'is invalid' do
        expect(form.valid?).to be(false)
        expect(form.errors[:evidence]).to include('Evidence must be 500 characters or fewer')
      end
    end

    context 'when evidence is valid' do
      subject(:form) { described_class.new(evidence: 'My evidence', subject: 'maths') }

      it 'is valid' do
        expect(form.valid?).to be(true)
      end
    end
  end
end

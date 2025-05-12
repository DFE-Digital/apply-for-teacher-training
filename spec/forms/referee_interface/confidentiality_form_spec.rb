require 'rails_helper'

RSpec.describe RefereeInterface::ConfidentialityForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:confidential) }

    describe '.build_from_reference' do
      context 'when the reference confidentiality is not set' do
        it 'initialises a form with confidential set to nil' do
          reference = build(:reference)
          form = described_class.build_from_reference(reference: reference)

          expect(form.confidential).to be_nil
        end
      end

      context 'when the reference is confidential' do
        it 'initialises a form with confidential set to true' do
          reference = build(:reference, confidential: true)
          form = described_class.build_from_reference(reference: reference)

          expect(form.confidential).to be(true)
        end
      end

      context 'when the reference is not confidential' do
        it 'initialises a form with confidential set to false' do
          reference = build(:reference, confidential: false)
          form = described_class.build_from_reference(reference: reference)

          expect(form.confidential).to be(false)
        end
      end
    end

    describe '#save' do
      let(:application_reference) { create(:reference, :feedback_requested) }

      context 'when the form is invalid' do
        it 'returns false and adds an error message' do
          form = described_class.new

          expect(form.save(application_reference)).to be(false)
          expect(form.errors[:confidential]).to include('Select yes if your reference can be shared')
        end
      end

      context 'when the form is valid and the reference is confidential' do
        it 'updates the reference confidentiality status' do
          form = described_class.new(confidential: 'true')
          form.save(application_reference)

          expect(application_reference.confidential).to be(true)
        end
      end

      context 'when the form is valid and the reference is not confidential' do
        it 'updates the reference confidentiality status' do
          form = described_class.new(confidential: 'false')
          form.save(application_reference)

          expect(application_reference.confidential).to be(false)
        end
      end
    end
  end
end

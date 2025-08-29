require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::SubjectForm do
  subject(:subject_form) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before do
    allow(store).to receive(:read)
  end

  describe 'validations' do
    context 'subject presence' do
      let(:degree_params) { { subject: '' } }

      it 'returns the correct validation message' do
        expect(subject_form.valid?).to be false
        expect(subject_form.errors[:subject]).to eq ['Enter your degree subject']
      end
    end

    context 'subject is free text and too long' do
      let(:degree_params) { { subject: Faker::Lorem.sentence(word_count: 256) } }

      it 'returns the correct validation message' do
        expect(subject_form.valid?).to be false
        expect(subject_form.errors[:subject]).to eq ['Your degree subject must be 255 characters or fewer']
      end
    end
  end

  describe '#subject' do
    let(:degree_params) do
      {
        subject: 'Chemistry',
        subject_raw:,
      }
    end

    context 'when subject raw is present' do
      let(:subject_raw) { 'Math' }

      it 'returns raw value' do
        expect(subject_form.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is empty' do
      let(:subject_raw) { '' }

      it 'returns raw value' do
        expect(subject_form.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is nil' do
      let(:subject_raw) { nil }

      it 'returns original value' do
        expect(subject_form.subject).to eq('Chemistry')
      end
    end
  end
end

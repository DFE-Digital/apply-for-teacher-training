require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::SubjectForm do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before do
    allow(store).to receive(:read)
    allow(Sentry).to receive(:capture_exception)
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
        expect(wizard.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is empty' do
      let(:subject_raw) { '' }

      it 'returns raw value' do
        expect(wizard.subject).to eq(subject_raw)
      end
    end

    context 'when subject raw is nil' do
      let(:subject_raw) { nil }

      it 'returns original value' do
        expect(wizard.subject).to eq('Chemistry')
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::UniversityForm do
  subject(:wizard) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before do
    allow(store).to receive(:read)
    allow(Sentry).to receive(:capture_exception)
  end

  describe '#university' do
    let(:degree_params) do
      {
        university: 'Oxford',
        university_raw:,
      }
    end

    context 'when university raw is present' do
      let(:university_raw) { 'Oxford' }

      it 'returns raw value' do
        expect(wizard.university).to eq(university_raw)
      end
    end

    context 'when university raw is nil' do
      let(:university_raw) { nil }

      it 'returns original value' do
        expect(wizard.university).to eq('Oxford')
      end
    end

    context 'when university raw is empty' do
      let(:university_raw) { '' }

      it 'returns original value' do
        expect(wizard.university).to eq('')
      end
    end
  end
end

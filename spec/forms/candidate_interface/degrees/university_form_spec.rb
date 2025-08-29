require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::UniversityForm do
  subject(:university_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before do
    allow(store).to receive(:read)
  end

  describe 'validations' do
    context 'university presence' do
      let(:degree_params) { { university: '' } }

      it 'returns the correct validation message' do
        expect(university_form.valid?).to be false
        expect(university_form.errors[:university]).to eq ['Enter the university that awarded your degree']
      end
    end

    context 'university is free text and too long' do
      let(:degree_params) { { university: Faker::Lorem.sentence(word_count: 256) } }

      it 'returns the correct validation message' do
        expect(university_form.valid?).to be false
        expect(university_form.errors[:university]).to eq ['University must be 255 characters or fewer']
      end
    end
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
        expect(university_form.university).to eq(university_raw)
      end
    end

    context 'when university raw is nil' do
      let(:university_raw) { nil }

      it 'returns original value' do
        expect(university_form.university).to eq('Oxford')
      end
    end

    context 'when university raw is empty' do
      let(:university_raw) { '' }

      it 'returns original value' do
        expect(university_form.university).to eq('')
      end
    end
  end
end

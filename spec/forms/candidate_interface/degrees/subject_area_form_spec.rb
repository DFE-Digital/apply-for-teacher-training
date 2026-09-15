require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::SubjectAreaForm do
  include Rails.application.routes.url_helpers

  subject(:subject_area_form) { described_class.new(store, degree_params) }

  let(:degree_params) { {} }

  let(:store) { instance_double(WizardStateStores::RailsCacheStore) }

  before do
    allow(store).to receive(:read)
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:subject_areas) }

    context 'number of subject_areas' do
      context 'when there are more than 2 subject areas' do
        let(:degree_params) { { subject_areas: [1, 2, 3] } }

        it 'returns invalid' do
          expect(subject_area_form.valid?).to be false
          expect(subject_area_form.errors[:subject_areas]).to eq(['Select up to 2 subject areas'])
        end
      end
    end
  end

  describe '#back_link' do
    context 'when reviewing and the subject is unchanged' do
      let(:degree_params) { { id: 123 } }

      it 'returns the review path' do
        expect(subject_area_form.back_link).to eq(candidate_interface_degree_review_path)
      end
    end

    context 'when reviewing and the subject is changed' do
      let(:degree_params) { { id: 123, subject: 'Sausage making' } }

      it 'returns the review path' do
        expect(subject_area_form.back_link).to eq(candidate_interface_degree_subject_path)
      end
    end
  end

  describe '#next_step' do
    context 'when reviewing and the country is unchanged' do
      let(:degree_params) { { id: 123 } }

      it 'returns the review path' do
        expect(subject_area_form.next_step).to eq(:review)
      end
    end

    context 'when reviewing and the country is changed' do
      let(:degree_params) { { id: 123, country: 'South Korea' } }

      it 'returns the review path' do
        expect(subject_area_form.next_step).to eq(:university)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::EnicReferenceForm do
  subject(:enic_reference_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    context 'enic_reference and comparable_uk_degree presence' do
      let(:degree_params) { { enic_reference: nil, comparable_uk_degree: nil } }

      it 'returns the correct error messages' do
        expect(enic_reference_form.valid?).to be false
        expect(enic_reference_form.errors[:enic_reference]).to eq ['Enter the UK ENIC reference number']
        expect(enic_reference_form.errors[:comparable_uk_degree]).to eq ['Select the comparable UK degree']
      end
    end
  end

  describe 'next step' do
    let(:degree_params) { {} }

    it 'returns review' do
      expect(enic_reference_form.next_step).to eq :review
    end
  end

  describe 'back_link' do
    context 'reviewing' do
      let(:degree_params) do
        { id: create(:degree_qualification, application_form:).id }
      end

      it 'returns to review' do
        expect(enic_reference_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_review_path
      end
    end

    context 'not reviewing' do
      let(:degree_params) { {} }

      it 'returns to enic reason path' do
        expect(enic_reference_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_enic_path
      end
    end
  end
end

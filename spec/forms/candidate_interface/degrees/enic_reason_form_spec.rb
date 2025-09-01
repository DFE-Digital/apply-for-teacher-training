require 'rails_helper'

RSpec.describe CandidateInterface::Degrees::EnicReasonForm do
  subject(:enic_reason_form) { described_class.new(store, degree_params) }

  let(:store) { instance_double(WizardStateStores::RedisStore) }
  let(:application_form) { create(:application_form) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    context 'enic reason presence' do
      let(:degree_params) { { enic_reason: nil } }

      it 'returns correct error message' do
        expect(enic_reason_form.valid?).to be false
        expect(enic_reason_form.errors[:enic_reason]).to eq ['Select whether you have a UK ENIC reference number or not']
      end
    end
  end

  describe 'sanitize_attrs' do
    # This method is called from the parent class when the class is initialised
    context 'enic has not been obtained' do
      let(:degree_params) do
        {
          enic_reason: 'maybe',
          enic_reference: '4000228363',
          comparable_uk_degree: 'Bachelors (ordinary)',
        }
      end

      it 'removes enic reference and comparable uk degree' do
        expect(enic_reason_form.enic_reason).to eq 'maybe'
        expect(enic_reason_form.enic_reference).to be_nil
        expect(enic_reason_form.comparable_uk_degree).to be_nil
      end
    end

    context 'enic has been obtained' do
      let(:degree_params) do
        {
          enic_reason: 'obtained',
          enic_reference: '4000228363',
          comparable_uk_degree: 'Bachelors (ordinary)',
        }
      end

      it 'does not remove enic reference and comparable uk degree' do
        expect(enic_reason_form.enic_reason).to eq 'obtained'
        expect(enic_reason_form.enic_reference).to eq '4000228363'
        expect(enic_reason_form.comparable_uk_degree).to eq 'Bachelors (ordinary)'
      end
    end
  end

  describe 'back_link' do
    context 'reviewing with changed completion answer' do
      let(:degree_params) do
        {
          id: create(:degree_qualification, application_form:, institution_country: 'GB', predicted_grade: true),
          completed: 'Yes',
        }
      end

      it 'returns to award year' do
        expect(enic_reason_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_award_year_path
      end
    end

    context 'not reviewing' do
      let(:degree_params) { {} }

      it 'returns to award year path' do
        expect(enic_reason_form.back_link).to eq Rails.application.routes.url_helpers.candidate_interface_degree_award_year_path
      end
    end
  end

  describe 'next_step' do
    context 'candidate has enic statement' do
      let(:degree_params) { { enic_reason: 'obtained' } }

      it 'returns enic_statement' do
        expect(enic_reason_form.next_step).to eq(:enic_reference)
      end
    end

    context 'candidate does not have an enic statement' do
      let(:degree_params) do
        { enic_reason: ApplicationQualification.enic_reasons.keys.filter { |r| r != 'obtained' }.sample }
      end

      it 'returns review' do
        expect(enic_reason_form.next_step).to eq(:review)
      end
    end
  end
end

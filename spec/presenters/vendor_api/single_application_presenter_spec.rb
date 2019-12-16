require 'rails_helper'

RSpec.describe VendorApi::SingleApplicationPresenter do
  describe 'attributes.candidate.nationality' do
    it 'returns nationality in the correct format' do
      application_form = create(:completed_application_form, :with_completed_references, first_nationality: 'British', second_nationality: 'American')
      application_choice = create(:application_choice, status: 'awaiting_provider_decision', application_form: application_form)

      response = VendorApi::SingleApplicationPresenter.new(application_choice).as_json

      expect(response.to_json).to be_valid_against_openapi_schema('Application')
      expect(response[:attributes][:candidate][:nationality]).to eq(%w[GB US])
    end
  end

  describe '#as_json' do
    context 'given a relation that includes application_qualifications' do
      let(:application_choice) do
        create(:application_choice, status: 'awaiting_provider_decision', application_form: create(:completed_application_form))
      end

      let(:given_relation) { GetApplicationChoicesForProvider.call(provider: application_choice.provider) }
      let!(:presenter) { VendorApi::SingleApplicationPresenter.new(given_relation.first) }

      it 'does not trigger any additional queries' do
        expect { presenter.as_json }.not_to make_database_queries
      end
    end
  end
end

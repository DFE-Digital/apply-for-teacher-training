require 'rails_helper'

RSpec.describe VendorAPI::ApplicationPresenter do
  subject(:application_json) { described_class.new(version, application_choice).as_json }

  let(:version) { '1.2' }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) { create(:completed_application_form, :with_equality_and_diversity_data) }
  let(:application_choice) { create(:application_choice, :with_recruited, application_form: application_form) }

  describe 'HESA data' do
    it 'returns the HESA codes associated with that application' do
      equality_and_diversity_data = application_form[:equality_and_diversity]
      expect(attributes).to include(
        {
          equality_and_diversity: {
            sex: equality_and_diversity_data['hesa_sex'],
            disability: equality_and_diversity_data['hesa_disabilities'],
            ethnicity: equality_and_diversity_data['hesa_ethnicity'],
            other_disability_details: equality_and_diversity_data['other_disability_details'],
            other_ethnicity_details: equality_and_diversity_data['other_ethnicity_details'],
          },
        },
      )
    end
  end
end

require 'rails_helper'

RSpec.describe 'ApplicationPresenter' do
  subject(:application_json) { application_presenter.new(version, application_choice).as_json }

  let(:application_presenter) { VendorAPI::ApplicationPresenter }
  let(:version) { '1.2' }
  let(:attributes) { application_json[:attributes] }
  let(:application_form) do
    create(
      :completed_application_form,
      :with_equality_and_diversity_data,
      recruitment_cycle_year:,
      with_disability_randomness: false,
    )
  end
  let(:application_choice) do
    create(:application_choice, :recruited, application_form: application_form)
  end

  describe 'Equality and diversity data' do
    context 'when it is a current cycle application' do
      let(:recruitment_cycle_year) { RecruitmentCycleTimetable.current_year }

      it 'returns the 2023 HESA codes associated with that application' do
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

    context 'when it is a previous cycle application' do
      let(:recruitment_cycle_year) { 2022 }

      it 'does not return the 2023 HESA codes associated with that applications' do
        expect(attributes).to include({
          equality_and_diversity: nil,
        })
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ReasonsForRejectionApplicationsQuery do
  describe '#call' do
    let!(:application_choice) { create(:application_choice, :with_structured_rejection_reasons) }
    let!(:application_choice_without_sr4r) { create(:application_choice) }
    let!(:application_choice_from_previous_year) do
      create(:application_choice, :with_structured_rejection_reasons, current_recruitment_cycle_year: RecruitmentCycle.previous_year)
    end
    let(:filter_params) do
      {
        structured_rejection_reasons: { 'candidate_behaviour_y_n' => 'Yes' },
        recruitment_cycle_year: RecruitmentCycle.current_year,
      }
    end

    subject(:query) { described_class.new(filter_params) }

    it 'filters by rejection reason key and recruitment cycle' do
      expect(query.call).to eq([application_choice])
    end
  end
end

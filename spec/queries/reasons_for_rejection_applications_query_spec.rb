require 'rails_helper'

RSpec.describe ReasonsForRejectionApplicationsQuery do
  describe '#call' do
    let!(:application_choice) do
      reject_application(
        {
          id: 'personal_statement',
          label: 'Personal statement',
          selected_reasons: [
            {
              id: 'quality_of_writing',
              label: 'Quality of writing',
              details: {
                id: 'quality_of_writing_details',
                text: 'The statement lack detail and depth',
              },
            },
          ],
        },
      )
    end
    let!(:second_application_choice) do
      reject_application(
        {
          id: 'visa_sponsorship',
          label: 'Visa sponsorship',
          details: {
            id: 'visa_sponsorship_details',
            text: 'Cannot sponsor visa',
          },
        },
      )
    end
    let!(:application_choice_without_sr4r) { create(:application_choice) }
    let!(:application_choice_from_previous_year) do
      create(:application_choice, :with_old_structured_rejection_reasons, current_recruitment_cycle_year: previous_year)
    end

    subject(:query) { described_class.new(filter_params) }

    context 'when searching for top level reasons' do
      let(:filter_params) do
        {
          structured_rejection_reasons: { 'id' => 'visa_sponsorship' },
          recruitment_cycle_year: current_year,
          page: 1,
        }
      end

      it 'filters by rejection reason key and recruitment cycle' do
        expect(query.call).to eq([second_application_choice])
      end
    end

    context 'when searching for sub groups' do
      let(:filter_params) do
        {
          structured_rejection_reasons: { 'personal_statement' => 'quality_of_writing' },
          recruitment_cycle_year: current_year,
          page: 1,
        }
      end

      it 'filters by rejection reason key and recruitment cycle' do
        expect(query.call).to eq([application_choice])
      end
    end

    def reject_application(reason)
      create(
        :application_choice,
        rejected_at: 2.minutes.ago,
        rejection_reasons_type: 'reasons_for_rejection',
        structured_rejection_reasons: {
          selected_reasons: [reason],
        },
      )
    end
  end
end

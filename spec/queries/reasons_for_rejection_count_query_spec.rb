require 'rails_helper'

RSpec.describe ReasonsForRejectionCountQuery do
  def reject_application(application_choice, reasons)
    ApplicationStateChange.new(application_choice).reject!
    application_choice.update!(
      structured_rejection_reasons: { selected_reasons: reasons },
      rejected_at: Time.zone.now,
    )
  end

  let(:qualifications) do
    {
      id: 'qualifications',
      label: 'Qualifications',
      selected_reasons: [
        {
          id: 'unsuitable_degree',
          label: 'Degree does not meet course requirements',
          details: {
            id: 'unsuitable_degree_details',
            text: 'details about this rejection',
          },
        },
      ],
    }
  end

  let(:visa_sponsorship) do
    {
      id: 'visa_sponsorship',
      label: 'Visa sponsorship',
      details: {
        id: 'visa_sponsorship_details',
        text: 'details about this rejection',
      },
    }
  end

  before do
    @application_choice1 = create(:application_choice, :awaiting_provider_decision)
    @application_choice2 = create(:application_choice, :awaiting_provider_decision)
    @application_choice3 = create(:application_choice, :awaiting_provider_decision)
    @application_choice4 = create(:application_choice, :awaiting_provider_decision)

    reject_application(
      @application_choice1,
      [qualifications, visa_sponsorship],
    )
    reject_application(
      @application_choice2,
      [visa_sponsorship],
    )
    reject_application(
      @application_choice3,
      [visa_sponsorship],
    )
    reject_application(
      @application_choice4,
      [{ qualification_y_or_n: 'Yes' }],
    )
    @application_choice3.update!(rejected_at: 2.months.ago)
  end

  describe '#grouped_reasons' do
    it 'returns correct values' do
      counts = described_class.new.grouped_reasons
      expect(counts[:visa_sponsorship]).to eq(
        described_class::Result.new(3, 2, {}),
      )
      expect(counts[:qualifications]).to eq(
        described_class::Result.new(1, 1, {}),
      )
    end

    it 'defaults to counts for current recruitment cycle' do
      reject_application(
        create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: previous_year),
        [qualifications, visa_sponsorship],
      )
      counts = described_class.new.grouped_reasons
      expect(counts[:visa_sponsorship]).to eq(described_class::Result.new(3, 2, {}))
      expect(counts[:qualifications]).to eq(described_class::Result.new(1, 1, {}))
    end

    it 'can be initialized for a specific recruitment cycle year' do
      reject_application(
        create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: previous_year),
        [visa_sponsorship, qualifications],
      )
      counts = described_class.new(previous_year).grouped_reasons
      expect(counts[:visa_sponsorship]).to eq(described_class::Result.new(1, 1, {}))
      expect(counts[:qualifications]).to eq(described_class::Result.new(1, 1, {}))
    end
  end

  describe '#subgrouped_reasons' do
    it 'returns correct values' do
      counts = described_class.new.subgrouped_reasons
      expect(counts[:qualifications].sub_reasons[:unsuitable_degree]).to eq(
        described_class::Result.new(1, 1, nil),
      )
      expect(counts[:visa_sponsorship].sub_reasons).to eq({})
    end

    it 'only returns counts for current recruitment cycle' do
      reject_application(
        create(:application_choice, :awaiting_provider_decision, current_recruitment_cycle_year: previous_year),
        [visa_sponsorship, qualifications],
      )
      counts = described_class.new.subgrouped_reasons
      expect(counts[:qualifications].sub_reasons[:unsuitable_degree]).to eq(described_class::Result.new(1, 1, nil))
      expect(counts[:visa_sponsorship]).to eq(described_class::Result.new(3, 2, {}))
    end
  end

  describe '#total_structured_reasons_for_rejection' do
    it 'returns the count of all applications with structured reasons for rejection' do
      expect(described_class.new.total_structured_reasons_for_rejection).to eq(4)
    end

    it 'returns the count of applications with structured reasons for rejection for this month' do
      expect(described_class.new.total_structured_reasons_for_rejection(time_period: :this_month)).to eq(3)
    end
  end
end

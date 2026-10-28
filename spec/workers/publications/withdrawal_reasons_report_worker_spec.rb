require 'rails_helper'

RSpec.describe Publications::WithdrawalReasonsReportWorker do # rubocop:disable RSpec/MultipleDescribes
  let!(:application_choice) { create(:application_choice, :awaiting_provider_decision) }

  describe '#perform' do
    it 'calls ProviderWithdrawalReasonsReportWorker' do
      described_class.new.perform

      expect(
        Publications::ProviderWithdrawalReasonsReportWorker,
      ).to have_been_enqueued.with(application_choice.provider.id)
    end
  end
end

RSpec.describe Publications::ProviderWithdrawalReasonsReportWorker do
  describe '#perform' do
    let(:provider_id) { 1 }

    it 'calls ProviderWithdrawalReasonsReportWorker' do
      generator = instance_double(
        Publications::WithdrawalReasonsReportGenerator,
        call: nil,
      )

      allow(Publications::WithdrawalReasonsReportGenerator).to receive(:new)
        .with(
          provider_id:,
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
        ).and_return(generator)

      described_class.new.perform(provider_id)
      expect(generator).to have_received(:call)
    end
  end
end

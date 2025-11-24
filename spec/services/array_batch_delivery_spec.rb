require 'rails_helper'

RSpec.describe ArrayBatchDelivery do
  describe '#each' do
    before { create_list(:candidate, 2) }

    context 'when the relation is an array' do
      before do
        allow(SendFindHasOpenedEmailToCandidatesBatchWorker).to receive(:perform_at)
      end

      it 'executes block' do
        stagger_over_default = 5.hours
        application_forms = create_list(:application_form, 3)
        relation = application_forms.pluck(:id)

        described_class.new(relation:, batch_size: 2).each do |batch_time, candidate_ids|
          SendFindHasOpenedEmailToCandidatesBatchWorker.perform_at(
            batch_time,
            candidate_ids,
          )
        end

        expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now, kind_of(Array)),
        )
        expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to(
          have_received(:perform_at).with(Time.zone.now + stagger_over_default, kind_of(Array)),
        )
      end
    end
  end
end

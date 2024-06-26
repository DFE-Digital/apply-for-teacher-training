require 'rails_helper'

RSpec.describe GroupedRelationBatchDelivery do
  describe '#each' do
    context 'where relation is not grouped' do
      let(:batch_deliver_subject) do
        described_class.new(relation: create_list(:candidate, 2)).each do |batch_time, candidates|
          SendFindHasOpenedEmailToCandidatesBatchWorker.perform_at(batch_time, candidates.pluck(:id))
        end
      end

      it 'fails to execute block' do
        expect { batch_deliver_subject }.to raise_error NoMethodError
      end
    end

    context 'where relation is grouped' do
      before do
        allow(SendFindHasOpenedEmailToCandidatesBatchWorker).to receive(:perform_at)
      end

      it 'executes block' do
        stagger_over_default = 5.hours
        application_forms = create_list(:application_form, 3)
        relation = ApplicationForm.where(id: application_forms.pluck(:id))
                                  .group('application_forms.id')

        described_class.new(relation:, batch_size: 2).each do |batch_time, candidates|
          SendFindHasOpenedEmailToCandidatesBatchWorker.perform_at(
            batch_time,
            candidates.pluck(:id),
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

require 'rails_helper'

RSpec.describe BatchDelivery do
  describe 'Staggered email sending' do
    let(:stagger_over) { 5.hours }

    before do
      @candidates = double

      allow(@candidates).to receive(:length).and_return(300)
      allow(@candidates).to receive(:find_in_batches).and_yield(
        (1..120).map { |id| Candidate.new(id:) },
      ).and_yield(
        (121..240).map { |id| Candidate.new(id:) },
      ).and_yield(
        (241..300).map { |id| Candidate.new(id:) },
      )
      allow(SendFindHasOpenedEmailToCandidatesBatchWorker).to receive(:perform_at)
    end

    it 'queues three staggered SendFindHasOpenedEmailToCandidatesBatchWorker jobs' do
      described_class.new(relation: @candidates).each do |batch_time, candidates|
        SendFindHasOpenedEmailToCandidatesBatchWorker.perform_at(
          batch_time,
          candidates.pluck(:id),
        )
      end

      expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to(
        have_received(:perform_at).with(Time.zone.now, (1..120).to_a),
      )
      expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to(
        have_received(:perform_at).with(Time.zone.now + (stagger_over / 2.0), (121..240).to_a),
      )
      expect(SendFindHasOpenedEmailToCandidatesBatchWorker).to(
        have_received(:perform_at).with(Time.zone.now + stagger_over, (241..300).to_a),
      )
    end
  end
end

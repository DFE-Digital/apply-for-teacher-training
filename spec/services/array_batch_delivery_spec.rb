require 'rails_helper'

RSpec.describe ArrayBatchDelivery do
  describe '#each' do
    context 'when the relation is an array' do
      let(:some_job) { double(ActiveJob) }
      let(:configured_job) { double(ActiveJob::ConfiguredJob) }

      before do
        allow(some_job).to receive(:set).and_return(configured_job)
        allow(configured_job).to receive(:perform_later).with(Array)
      end

      it 'executes block' do
        relation = [1,2,3]

        described_class.new(relation:, batch_size: 2).each do |batch_time, candidate_ids|
          some_job.set(wait_until: batch_time).perform_later(candidate_ids)
        end

        expect(some_job).to have_received(:set).twice
        expect(configured_job).to have_received(:perform_later).with(Array).twice
      end
    end
  end
end

require 'rails_helper'

RSpec.describe GroupedRelationBatchDelivery do
  let(:some_job) { double(ActiveJob) }
  let(:configured_job) { double(ActiveJob::ConfiguredJob) }

  before do
    allow(some_job).to receive(:set).and_return(configured_job)
    allow(configured_job).to receive(:perform_later).with(Array)
  end

  describe '#each' do
    context 'where relation is not grouped' do
      let(:batch_deliver_subject) do
        described_class.new(relation: create_list(:candidate, 2)).each do |batch_time, candidates|
          some_job.set(wait_until: batch_time).perform_later(candidates.pluck(:id))
        end
      end

      it 'fails to execute block' do
        expect { batch_deliver_subject }.to raise_error NoMethodError
      end
    end

    context 'where relation is grouped' do
      it 'executes block' do
        stagger_over_default = 5.hours
        application_forms = create_list(:application_form, 3)
        relation = ApplicationForm.where(id: application_forms.pluck(:id))
                                  .group('application_forms.id')

        described_class.new(relation:, batch_size: 2).each do |batch_time, candidates|
          some_job.set(wait_time: batch_time).perform_later(candidates.pluck(:id))
        end


        expect(some_job).to have_received(:set).twice
        expect(configured_job).to have_received(:perform_later).with(Array).twice
      end
    end
  end
end

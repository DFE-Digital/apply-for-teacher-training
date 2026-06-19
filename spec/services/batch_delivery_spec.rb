require 'rails_helper'

RSpec.describe BatchDelivery do
  let(:some_job) { instance_double(ApplicationJob) }
  let(:configured_job) { instance_double(ActiveJob::ConfiguredJob) }

  before do
    allow(some_job).to receive(:set).and_return(configured_job)
    allow(configured_job).to receive(:perform_later).with(Array)
  end

  describe '#each' do
    context 'where relation is grouped' do
      let(:application_forms) { create_list(:application_form, 3) }
      let(:grouped_relation) do
        ApplicationForm.where(id: application_forms.pluck(:id))
                       .group('application_forms.id')
      end

      let(:batch_deliver_subject) do
        described_class.new(relation: create_list(:candidate, 2)).each do |batch_time, candidates|
          some_job.set(wait_until: batch_time).perform_later(candidates.pluck(:id))
        end
      end

      it 'fails to execute block' do
        expect { batch_deliver_subject }.to raise_error NoMethodError
      end
    end

    context 'where relation is not grouped' do
      it 'executes block' do
        application_forms = create_list(:application_form, 3)
        relation = ApplicationForm.where(id: application_forms.pluck(:id))

        described_class.new(relation:, batch_size: 2).each do |batch_time, candidates|
          some_job.set(wait_until: batch_time).perform_later(candidates.pluck(:id))
        end

        expect(some_job).to have_received(:set).twice
        expect(configured_job).to have_received(:perform_later).with(Array).twice
      end
    end
  end
end

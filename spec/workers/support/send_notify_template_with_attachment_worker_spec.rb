require 'rails_helper'

RSpec.describe Support::SendNotifyTemplateWithAttachmentWorker do
  let(:notify_request) do
    create(:notify_send_request, email_addresses:)
  end

  describe '#perform' do
    let(:email_addresses) { %w[user_1@exmaple.com user_2@example.com user_3@example.com] }

    it 'enqueues a Support::SendNotifyTemplateWithAttachmentBatchWorker' do
      expect { described_class.new.perform(notify_request.id) }.to enqueue_job(Support::SendNotifyTemplateWithAttachmentBatchWorker)
         .with(
           %w[user_1@exmaple.com user_2@example.com user_3@example.com],
           notify_request.id,
         ).once
    end

    context 'when the request has a large number of email addresses' do
      let(:email_addresses) { 200.times.map { |n| "user_#{n}@example.com" } }

      it 'enqueues a batch of Support::SendNotifyTemplateWithAttachmentBatchWorkers' do
        expect { described_class.new.perform(notify_request.id) }.to enqueue_job(Support::SendNotifyTemplateWithAttachmentBatchWorker).twice
      end
    end
  end
end

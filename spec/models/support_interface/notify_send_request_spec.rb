require 'rails_helper'

RSpec.describe SupportInterface::NotifySendRequest do
  describe 'associations' do
    it { is_expected.to belong_to(:support_user) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:template_id) }
    it { is_expected.to validate_presence_of(:email_addresses) }
  end

  describe "attachments" do
    it { is_expected.to have_one_attached(:file) }
  end

  describe "#send_emails" do
    subject(:send_emails) { notify_request.send_emails }

    let(:notify_request) { create(:notify_send_request) }

    before do
      allow(Support::SendNotifyTemplateWithAttachmentWorker).to receive(:perform_async)

      send_emails
    end

    it "triggers a Support::SendNotifyTemplateWithAttachmentWorker" do
      expect(Support::SendNotifyTemplateWithAttachmentWorker).to have_received(:perform_async)
        .with(
          notify_request.id,
        ).once
    end
  end
end

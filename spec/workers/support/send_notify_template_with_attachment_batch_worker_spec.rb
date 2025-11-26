require 'rails_helper'

RSpec.describe Support::SendNotifyTemplateWithAttachmentBatchWorker, :sidekiq do
  let(:notify_request) do
    create(:notify_send_request, email_addresses:)
  end
  let(:email_addresses) { %w[user_1@exmaple.com user_2@example.com] }

  before do
    @notify_instance = instance_double(Notifications::Client)
    allow(Notifications::Client).to receive(:new).and_return(@notify_instance)
    allow(@notify_instance).to receive(:send_email).and_return(true)

    attachment = File.open('spec/fixtures/send_notify_template/hello_world.txt')
    notify_request.file.attach(attachment)
  end

  it 'sends a email with an attachment per email address' do
    described_class.new.perform(email_addresses, notify_request.id)

    expect(@notify_instance).to have_received(:send_email).twice
  end
end

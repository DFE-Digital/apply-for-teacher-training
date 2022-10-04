require 'rails_helper'

RSpec.describe Healthchecks::NotifyCheck do
  subject { described_class.new }

  let(:notify_client) { instance_double(Notifications::Client) }

  let(:response_class) do
    Class.new do
      def initialize(body:, code: 500)
        @code = code
        @body = body
      end

      attr_reader :code, :body
    end
  end

  before do
    allow(Notifications::Client).to receive(:new).and_return(notify_client)
  end

  context 'when the Notify API is working normally' do
    before do
      allow(notify_client).to receive(:send_email)
        .and_return(instance_double(Notifications::Client::ResponseNotification))
    end

    it { is_expected.to be_successful_check }
    it { is_expected.to have_message('Notify is working') }
  end

  context 'when the Notify API is not working' do
    before do
      allow(notify_client).to receive(:send_email)
        .and_raise(Notifications::Client::RequestError, response_class.new(body: 'Notify is down'))
    end

    it { is_expected.not_to be_successful_check }
    it { is_expected.to have_message('Notify email sending failed: Notify is down') }
  end
end

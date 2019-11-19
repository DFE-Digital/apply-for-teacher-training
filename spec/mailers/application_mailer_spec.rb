require 'rails_helper'

RSpec.describe ApplicationMailer do
  describe 'when Notify throws an exception' do
    let(:fake_mailer) do
      Class.new(described_class) do
        def notify_error
          notify_request_stub = Struct.new(:code, :body).new(400, 'irrelevant')
          raise Notifications::Client::BadRequestError.new(notify_request_stub)
        end
      end
    end

    it 'rescues the exception and reports it to sentry' do
      allow(Raven).to receive(:capture_exception)

      fake_mailer.notify_error.deliver_now

      expect(Raven).to have_received(:capture_exception)
    end
  end
end

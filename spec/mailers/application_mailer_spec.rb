require 'rails_helper'

RSpec.describe ApplicationMailer, :sidekiq do
  describe '.rescue_from' do
    fake_mailer = Class.new(ApplicationMailer) do
      self.delivery_method = :notify
      self.notify_settings = {
        api_key: 'not-real-e1f4c969-b675-4a0d-a14d-623e7c2d3fd8-24fea27b-824e-4259-b5ce-1badafe98150',
      }

      def test_notify_error
        notify_email(
          to: 'test@example.com',
          subject: 'Some subject',
        )
      end
    end

    it 'marks errors as failed and re-raises the error' do
      stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
        .to_return(status: 404)

      expect {
        fake_mailer.test_notify_error.deliver_now
      }.to raise_error(Notifications::Client::NotFoundError)

      expect(Email.last.delivery_status).to eql('notify_error')
    end
  end
end

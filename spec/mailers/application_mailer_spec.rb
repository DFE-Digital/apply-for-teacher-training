require 'rails_helper'

RSpec.describe ApplicationMailer do
  describe 'exceptions' do
    context 'when Notify returns a team-only API key error' do
      let(:fake_mailer) do
        Class.new(described_class) do
          def notify_error
            notify_request_stub = Struct.new(:code, :body).new(
              400,
              'BadRequestError: Can’t send to this recipient using a team-only API key',
            )

            raise Notifications::Client::BadRequestError.new(notify_request_stub)
          end
        end
      end

      it 'returns a NotifyTeamOnlyAPIKeyError' do
        expect { fake_mailer.notify_error.deliver_now }.to raise_error(
          ApplicationMailer::NotifyTeamOnlyAPIKeyError,
          'BadRequestError: Can’t send to this recipient using a team-only API key',
        )
      end
    end

    context 'when Notify returns any other error' do
      let(:fake_mailer) do
        Class.new(described_class) do
          def notify_error
            notify_request_stub = Struct.new(:code, :body).new(
              400,
              'BadRequestError: Document didn’t pass the virus scan',
            )

            raise Notifications::Client::BadRequestError.new(notify_request_stub)
          end
        end
      end

      it 'raises a NotifyOtherBadRequestError' do
        expect { fake_mailer.notify_error.deliver_now }.to raise_error(
          ApplicationMailer::NotifyOtherBadRequestError,
          'BadRequestError: Document didn’t pass the virus scan',
        )
      end
    end
  end
end

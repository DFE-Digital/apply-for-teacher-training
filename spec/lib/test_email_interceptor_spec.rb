require 'rails_helper'

RSpec.describe TestEmailInterceptor do
  it 'intercepts example emails' do
    message = Mail::Message.new(to: ['test@example.com'])

    described_class.delivering_email(message)

    expect(message.perform_deliveries).to be false
  end

  it 'will let other emails be delivered' do
    message = Mail::Message.new(to: ['test@no-example.com'])

    described_class.delivering_email(message)

    expect(message.perform_deliveries).to be true
  end
end

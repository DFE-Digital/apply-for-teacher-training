require 'rails_helper'

RSpec.describe EnvironmentFlagInterceptor do
  it 'adds the environment to the email' do
    message = Mail::Message.new(subject: 'Hi hello')

    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
      described_class.delivering_email(message)
    end

    expect(message.subject).to eql '[EXAMPLE_ENV] Hi hello'
  end

  it 'does not add the environment to production emails' do
    message = Mail::Message.new(subject: 'Hi hello')

    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
      described_class.delivering_email(message)
    end

    expect(message.subject).to eql 'Hi hello'
  end
end

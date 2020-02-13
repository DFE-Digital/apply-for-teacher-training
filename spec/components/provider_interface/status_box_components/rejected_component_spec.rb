require 'rails_helper'

RSpec.describe ProviderInterface::StatusBoxComponents::RejectedComponent do
  it 'displays offer_withdrawn_rows if offer_withdrawn_at is set' do
    application_choice = instance_double(ApplicationChoice)
    allow(application_choice).to receive(:status).and_return('rejected')
    allow(application_choice).to receive(:offer_withdrawn_at).and_return(Time.now)
  end

  it 'displays rejected_rows if offer_withdrawn_at is not set' do
    application_choice = instance_double(ApplicationChoice)
    allow(application_choice).to receive(:status).and_return('rejected')
    allow(application_choice).to receive(:offer_withdrawn_at).and_return(nil)
  end
end

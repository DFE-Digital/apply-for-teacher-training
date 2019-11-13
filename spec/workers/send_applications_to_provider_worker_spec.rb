require 'rails_helper'

RSpec.describe SendApplicationsToProviderWorker do
  it 'delegates the work to a service class' do
    service = instance_double(SendApplicationsToProvider, call: true)
    allow(SendApplicationsToProvider).to receive(:new).and_return(service)
    SendApplicationsToProviderWorker.new.perform
    expect(service).to have_received(:call)
  end
end

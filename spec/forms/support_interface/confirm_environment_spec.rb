require 'rails_helper'

RSpec.describe SupportInterface::ConfirmEnvironment do
  it 'checks the confirmed environment against the hosting environment' do
    allow(HostingEnvironment).to receive(:environment_name).and_return('foo')
    expect(described_class.new(environment: 'foo')).to be_valid
    expect(described_class.new(environment: 'bar')).not_to be_valid
  end
end

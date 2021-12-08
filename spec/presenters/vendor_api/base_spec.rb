require 'rails_helper'

RSpec.describe VendorAPI::Base do
  subject(:presenter) { PresenterClass.new(version) }

  let(:version) { '1.0' }
  let(:presenter_class) { Class.new(described_class) }

  before do
    stub_const('PresenterClass', presenter_class)
  end

  it 'sets the active version' do
    expect(presenter.active_version).to eq(version)
  end
end

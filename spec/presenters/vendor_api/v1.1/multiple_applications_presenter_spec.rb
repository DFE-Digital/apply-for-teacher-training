require 'rails_helper'

RSpec.describe VendorAPI::MultipleApplicationsPresenter do
  describe '#applications_scope' do
    let(:applications) { ApplicationChoice }

    it 'performs a batch find' do
      allow(applications).to receive(:find_each).and_call_original
      described_class.new('1.0', applications).applications_scope
      expect(applications).to have_received(:find_each).with(batch_size: 500)
    end
  end
end

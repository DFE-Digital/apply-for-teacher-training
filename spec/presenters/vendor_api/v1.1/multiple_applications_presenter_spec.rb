require 'rails_helper'

RSpec.describe 'MultipleApplicationsPresenter' do
  describe '#applications_scope' do
    let(:multiple_applications_presenter) { VendorAPI::MultipleApplicationsPresenter }
    let(:applications) { ApplicationChoice }

    it 'performs a batch find' do
      allow(applications).to receive(:find_each).and_call_original
      multiple_applications_presenter.new('1.0', applications).applications_scope
      expect(applications).to have_received(:find_each).with(batch_size: 500)
    end
  end
end

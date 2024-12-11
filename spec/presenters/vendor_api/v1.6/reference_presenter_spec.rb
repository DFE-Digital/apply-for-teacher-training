require 'rails_helper'

RSpec.describe VendorAPI::ReferencePresenter do
  subject(:reference_schema) { described_class.new(version, reference).schema }

  let(:version) { '1.6' }

  describe 'confidentiality status' do
    let(:reference) { create(:reference) }

    it 'includes confidential' do
      expect(reference_schema[:confidential]).to be_present
    end
  end
end

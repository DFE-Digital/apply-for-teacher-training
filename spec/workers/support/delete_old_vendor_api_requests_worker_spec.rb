require 'rails_helper'

RSpec.describe Support::DeleteOldVendorAPIRequestsWorker do
  describe '#perform' do
    it 'deletes old vendor api requests' do
      deletable_record = create(:vendor_api_request_v2, created_at: 4.months.ago)
      create(:vendor_api_request_v2, created_at: 3.days.ago)

      expect { described_class.new.perform }.to change { VendorAPIRequestV2.count }.by(-1)
      expect { deletable_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
